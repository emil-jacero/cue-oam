package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Namespace Transformer - Creates Kubernetes Namespace with optional ResourceQuota and NetworkPolicies
#NamespaceTransformer: core.#Transformer & {
	creates: "k8s.io/api/core/v1.Namespace"

	required: [
		"k8s.io/api/core/v1.Namespace",
	]

	optional: []

	// Default values for various traits.
	// These are automatically included for optional traits if not specified in the component.
	defaults: {...} // see #Transformer interface

	registry: trait.#TraitRegistry

	validates: {
		// This transformer creates namespaces for components or applications
	}

	transform: {
		component: core.#Component
		context:   core.#ProviderContext

		// Extract namespace trait
		let _namespace = component.namespace

		output: [
			schema.#Namespace & {
				metadata: #GenerateMetadata & {
					_input: {
						name:         _namespace.name
						traitMeta:    component.#metadata
						context:      context
						resourceType: "namespace"
					}
				}
				metadata: name: _namespace.name
				metadata: {
					if _namespace.labels != _|_ {
						labels: _namespace.labels
					}
					if _namespace.annotations != _|_ {
						annotations: _namespace.annotations
					}
				}
			},
		]
	}
}
