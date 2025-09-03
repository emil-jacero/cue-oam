package transformer

import (
	"jacero.io/oam/v3alpha1/core"
)

// Enhanced Kubernetes transformer that renders trait outputs
#EnhancedKubernetesTransformer: {
	// Input module
	#module: core.#Module
	
	// Output as a flat list of Kubernetes resources
	resources: [...#KubernetesResource]
	
	// Collect all Kubernetes outputs from components
	resources: [
		for name, component in #module.components
		if component.#kubernetesOutput != _|_
		for resource in component.#kubernetesOutput {
			resource
		}
	]
}

// Base Kubernetes resource structure (reuse from existing transformer)
#KubernetesResource: {
	apiVersion: string
	kind:       string
	metadata:   #KubernetesMetadata
	spec:       {...}
	...
}

#KubernetesMetadata: {
	name:       string
	namespace?: string
	labels?: [string]:      string
	annotations?: [string]: string
	...
}