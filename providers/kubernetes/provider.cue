package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
)

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
	}

	transformers: {
		// Primary trait transformers (handle modifier traits internally)
		"core.oam.dev/v2alpha2.ContainerSet":           #ContainerSetTransformer
		"core.oam.dev/v2alpha2.Expose":                 #ExposeTransformer
		"core.oam.dev/v2alpha2.Volume":                 #VolumeTransformer
		"core.oam.dev/v2alpha2.Secret":                 #SecretTransformer
		"core.oam.dev/v2alpha2.Config":                 #ConfigTransformer
		"core.oam.dev/v2alpha2.NetworkIsolationScope":  #NetworkIsolationScopeTransformer
		// "core.oam.dev/v2alpha1.Labels":                 #LabelsTransformer
		// "core.oam.dev/v2alpha1.Annotations":            #AnnotationsTransformer
	}

	render: {
		app: core.#Application
		output: {
			resources: [
				// Flatten all transformer outputs into a single array
				for componentName, component in app.components
				for traitName, trait in component.#metadata.#traits
				if transformers[trait.#combinedVersion] != _|_
				for resource in (transformers[trait.#combinedVersion].transform & {
					input: component
					context: core.#ProviderContext & {
						namespace:     app.#metadata.namespace
						appName:       app.#metadata.name
						appVersion:    app.#metadata.version
						appLabels:     app.#metadata.labels
						componentName: componentName
						componentId:   component.#metadata.#id
						capabilities:  #metadata.capabilities
					}
				}).output.resources {
					resource
				},
			]
		}
	}
}
