package kubernetes

import (
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
	}

	// Transformers define which traits this provider supports.
	// Supported traits have transformer definitions, unsupported traits can be:
	// - Set to null (explicit unsupported)
	// - Omitted entirely (implicit unsupported)
	transformers: {
		// Supported OAM atomic traits - provider has transformers for these
		"core.oam.dev/v2alpha2.ContainerSet": #ContainerSetTransformer
		"core.oam.dev/v2alpha2.Expose":       #ExposeTransformer
		"core.oam.dev/v2alpha2.Volume":       #VolumeTransformer
		"core.oam.dev/v2alpha2.Secret":       #SecretTransformer
		"core.oam.dev/v2alpha2.Config":       #ConfigTransformer

		// Kubernetes platform-specific traits
		"k8s.io/api/core/v1.Namespace": #NamespaceTransformer

		// OAM traits not yet supported (handled internally by other transformers or not implemented)
		// These are explicitly marked as null, but could also be omitted entirely
		"core.oam.dev/v2alpha2.Replica":               null
		"core.oam.dev/v2alpha2.RestartPolicy":         null
		"core.oam.dev/v2alpha2.UpdateStrategy":        null
		"core.oam.dev/v2alpha2.NetworkIsolationScope": null
		"core.oam.dev/v2alpha1.Labels":                null
		"core.oam.dev/v2alpha1.Annotations":           null

		// Kubernetes resources - not yet implemented
		// Using null to explicitly indicate these are recognized but not supported
		"k8s.io/api/core/v1.Pod":                            null
		"k8s.io/api/core/v1.Service":                        null
		"k8s.io/api/core/v1.ConfigMap":                      null
		"k8s.io/api/core/v1.Secret":                         null
		"k8s.io/api/core/v1.PersistentVolumeClaim":          null
		"k8s.io/api/core/v1.ServiceAccount":                 null
		"k8s.io/api/apps/v1.Deployment":                     null
		"k8s.io/api/apps/v1.StatefulSet":                    null
		"k8s.io/api/apps/v1.DaemonSet":                      null
		"k8s.io/api/batch/v1.Job":                           null
		"k8s.io/api/batch/v1.Jobs":                          null
		"k8s.io/api/batch/v1.CronJob":                       null
		"k8s.io/api/rbac/v1.Role":                           null
		"k8s.io/api/rbac/v1.RoleBinding":                    null
		"k8s.io/api/rbac/v1.ClusterRole":                    null
		"k8s.io/api/rbac/v1.ClusterRoleBinding":             null
		"k8s.io/api/networking/v1.Ingress":                  null
		"k8s.io/api/networking/v1.NetworkPolicy":            null
		"k8s.io/api/autoscaling/v2.HorizontalPodAutoscaler": null
		"k8s.io/api/autoscaling/v2.VerticalPodAutoscaler":   null
		"k8s.io/api/policy/v1.PodDisruptionBudget":          null
		"k8s.io/api/policy/v1.PodSecurityPolicy":            null
		"k8s.io/api/storage/v1.StorageClass":                null
		"k8s.io/api/storage/v1.VolumeAttachment":            null
		"k8s.io/api/scheduling/v1.PriorityClass":            null
		"monitoring.coreos.com/v1.PodMonitor":               null
		"monitoring.coreos.com/v1.ServiceMonitor":           null
		"gateway.networking.k8s.io/v1.HTTPRoute":            null
		"gateway.networking.k8s.io/v1.GRPCRoute":            null
	}

	render: {
		app: core.#Application

		// Process all components and traits

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
				// Only process atomic traits that have valid transformers
				if trait.type == "atomic" && transformers[trait.requiredCapability] != _|_ {
					let t = transformers[trait.requiredCapability]

					// Verify transformer accepts the trait
					if t.accepts != trait.requiredCapability {
						error("Transformer mismatch: trait \(trait.requiredCapability) cannot be handled by its assigned transformer")
					}

					for resource in (t.transform & {
						input: comp
						context: core.#ProviderContext & {
							name:      app.#metadata.name
							namespace: app.#metadata.namespace
							// Only include traits that have valid transformers (not null or undefined)
							capabilities: [for trait, transformer in transformers if transformer != null && transformer != _|_ {trait}]

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
