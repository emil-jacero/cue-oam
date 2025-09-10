package kubernetes

import (
	"list"
	"strings"

	core "jacero.io/oam/core/v2alpha2"
)

// Kubernetes-specific metadata generation function
#GenerateMetadata: {
	_input: {
		name?:        string
		traitMeta:    _ // Accept any trait metadata structure
		context:      core.#ProviderContext
		resourceType: string // "deployment", "service", "configmap", etc.
	}

	// Metadata structure
	if _input.name != _|_ {
		name: _input.name
	}
	if _input.name == _|_ {
		name: _input.context.metadata.component.name
	}
	namespace: _input.context.namespace

	// Hierarchical label inheritance: System → Application → Component  
	labels: {
		// Standard Kubernetes recommended labels (system defaults)
		"app.kubernetes.io/name":       _input.name
		"app.kubernetes.io/instance":   _input.context.metadata.application.name
		"app.kubernetes.io/version":    _input.context.metadata.application.version
		"app.kubernetes.io/component":  _input.resourceType
		"app.kubernetes.io/part-of":    _input.context.metadata.application.name
		"app.kubernetes.io/managed-by": "cue-oam"

		// OAM-specific labels (conditionally added if fields exist)
		if _input.traitMeta.domain != _|_ {
			"oam.dev/trait-domain": _input.traitMeta.domain
		}
		if _input.traitMeta.type != _|_ {
			"oam.dev/trait-type": _input.traitMeta.type
		}
		"oam.dev/application": _input.context.metadata.application.name
		"oam.dev/component":   _input.context.metadata.component.name
	}

	// Merge in application-level labels if present
	if _input.context.metadata.application.labels != _|_ {
		for lk, lv in _input.context.metadata.application.labels {
			labels: "\(lk)": "\(lv)"
		}
	}

	// Merge in component-level labels if present  
	if _input.context.metadata.component.labels != _|_ {
		for lk, lv in _input.context.metadata.component.labels {
			labels: "\(lk)": "\(lv)"
		}
	}

	// Merge in trait labels if present
	if _input.traitMeta.labels != _|_ {
		for lk, lv in _input.traitMeta.labels {
			labels: "\(lk)": "\(lv)"
		}
	}

	// System annotations
	annotations: {
		if _input.traitMeta.requiredCapability != _|_ {
			"oam.dev/required-capabilities": _input.traitMeta.requiredCapability
		}
		if _input.traitMeta.requiredCapabilities != _|_ {
			"oam.dev/required-capabilities": _input.traitMeta.requiredCapabilities
		}
		"oam.dev/resource-type":       _input.resourceType
		"oam.dev/generated-by":        "cue-oam-transformer"
		"oam.dev/application-version": _input.context.metadata.application.version
	}

	// Merge in application annotations if present
	if _input.context.metadata.application.annotations != _|_ {
		for ak, av in _input.context.metadata.application.annotations {
			annotations: "\(ak)": "\(av)"
		}
	}

	// Merge in component annotations if present
	if _input.context.metadata.component.annotations != _|_ {
		for ak, av in _input.context.metadata.component.annotations {
			annotations: "\(ak)": "\(av)"
		}
	}

	// Merge in trait annotations if present
	if _input.traitMeta.annotations != _|_ {
		for ak, av in _input.traitMeta.annotations {
			annotations: "\(ak)": "\(av)"
		}
	}
}

#ProviderKubernetes: core.#Provider & {
	#metadata: {
		name:        "Kubernetes"
		description: "Provider that renders resources for Kubernetes."
		minVersion:  "v1.31.0" // Minimum supported Kubernetes version
		capabilities: [
			// Supported OAM atomic traits
			"core.oam.dev/v2alpha2.ContainerSet",
			"core.oam.dev/v2alpha2.Replica",
			"core.oam.dev/v2alpha2.RestartPolicy",
			"core.oam.dev/v2alpha2.UpdateStrategy",
			"core.oam.dev/v2alpha2.Expose",
			"core.oam.dev/v2alpha2.Volume",
			"core.oam.dev/v2alpha2.Secret",
			"core.oam.dev/v2alpha2.Config",
			"core.oam.dev/v2alpha2.NetworkIsolationScope",
			"core.oam.dev/v2alpha1.Labels",
			"core.oam.dev/v2alpha1.Annotations",

			// Supported Kubernetes resources
			"k8s.io/api/core/v1.Pod",
			"k8s.io/api/core/v1.Service",
			"k8s.io/api/apps/v1.Deployment",
			"k8s.io/api/apps/v1.StatefulSet",
			"k8s.io/api/apps/v1.DaemonSet",
			"k8s.io/api/batch/v1.Job",
			"k8s.io/api/batch/v1.CronJob",
			"k8s.io/api/rbac/v1.Role",
			"k8s.io/api/rbac/v1.RoleBinding",
			"k8s.io/api/networking/v1.Ingress",
			"k8s.io/api/networking/v1.NetworkPolicy",
			"k8s.io/api/core/v1.ConfigMap",
			"k8s.io/api/core/v1.Secret",
			"k8s.io/api/core/v1.PersistentVolumeClaim",
		]

		// Core traits that create primary resources - MUST be supported
		// If these are missing transformers, the provider should error
		coreTraits: [
			"core.oam.dev/v2alpha2.ContainerSet",
			"core.oam.dev/v2alpha2.Expose",
			"core.oam.dev/v2alpha2.Volume",
			"core.oam.dev/v2alpha2.Secret",
			"core.oam.dev/v2alpha2.Config",
			"core.oam.dev/v2alpha2.NetworkIsolationScope",
		]

		// Modifier traits that depend on other traits - can be safely ignored if unsupported
		// These traits modify resources created by core traits
		modifierTraits: [
			"core.oam.dev/v2alpha2.Replica",
			"core.oam.dev/v2alpha2.RestartPolicy",
			"core.oam.dev/v2alpha2.UpdateStrategy",
			"core.oam.dev/v2alpha1.Labels",
			"core.oam.dev/v2alpha1.Annotations",
		]
	}

	transformers: {
		// Primary trait transformers (handle modifier traits internally)
		"core.oam.dev/v2alpha2.ContainerSet":          #ContainerSetTransformer
		"core.oam.dev/v2alpha2.Expose":                #ExposeTransformer
		"core.oam.dev/v2alpha2.Volume":                #VolumeTransformer
		"core.oam.dev/v2alpha2.Secret":                #SecretTransformer
		"core.oam.dev/v2alpha2.Config":                #ConfigTransformer
		"core.oam.dev/v2alpha2.NetworkIsolationScope": #NetworkIsolationScopeTransformer
	}

	render: {
		app: core.#Application

		// Capability verification - check all traits used in the application
		#traitVerification: {
			// Collect all trait types used in the application
			usedTraits: [
				for componentName, comp in app.components
				for traitName, trait in comp.#metadata.#traits {
					trait.#combinedVersion
				},
			]

			// Check for unsupported core traits (these should error)
			unsupportedCoreTraits: [
				for usedTrait in usedTraits
				if list.Contains(#metadata.coreTraits, usedTrait) && transformers[usedTrait] == _|_ {
					usedTrait
				},
			]

			// Check for unsupported modifier traits (these are safely ignored)
			unsupportedModifierTraits: [
				for usedTrait in usedTraits
				if list.Contains(#metadata.modifierTraits, usedTrait) && transformers[usedTrait] == _|_ {
					usedTrait
				},
			]

			// Error if core traits are unsupported
			if len(unsupportedCoreTraits) > 0 {
				error("Core traits not supported by Kubernetes provider: \(strings.Join(unsupportedCoreTraits, ", ")). These traits create primary resources and must have transformers implemented.")
			}
		}

		output: {
			// Kubernetes List object format
			apiVersion: "v1"
			kind:       "List"
			metadata: {
				name:      app.#metadata.name
				namespace: app.#metadata.namespace
			}
			items: [
				// Flatten all transformer outputs into a single array
				for componentName, comp in app.components
				for traitName, trait in comp.#metadata.#traits
				if transformers[trait.#combinedVersion] != _|_ {
					// Verify transformer accepts the trait (additional safety check)
					if transformers[trait.#combinedVersion].accepts != trait.#combinedVersion {
						error("Transformer mismatch: trait \(trait.#combinedVersion) cannot be handled by its assigned transformer")
					}

					for resource in (transformers[trait.#combinedVersion].transform & {
						input: comp
						context: core.#ProviderContext & {
							name:         app.#metadata.name
							namespace:    app.#metadata.namespace
							capabilities: #metadata.capabilities

							metadata: {
								application: {
									id:        app.#metadata.#id
									name:      app.#metadata.name
									namespace: app.#metadata.namespace
									version:   app.#metadata.version
									if app.#metadata.labels != _|_ {
										labels: app.#metadata.labels
									}
									if app.#metadata.annotations != _|_ {
										annotations: app.#metadata.annotations
									}
								}

								component: {
									id:   comp.#metadata.#id
									name: comp.#metadata.name
									if comp.#metadata.labels != _|_ {
										labels: comp.#metadata.labels
									}
									if comp.#metadata.annotations != _|_ {
										annotations: comp.#metadata.annotations
									}
								}
							}
						}
					}).output.resources {
						resource
					}
				},
			]
		}
	}
}
