package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/governance"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Namespace Transformer - Creates Kubernetes Namespace with optional ResourceQuota and NetworkPolicies
#NamespaceTransformer: core.#Transformer & {
	accepts: "k8s.io/api/core/v1.Namespace"
	transform: {
		input:   trait.#Namespace
		context: core.#ProviderContext
		output: {
			let namespaceSpec = input.namespace
			let meta = input.#metadata
			let ctx = context

			resources: [
				// Namespace resource
				schema.#Namespace & {
					metadata: #GenerateMetadata & {
						_input: {
							name:         meta.name
							traitMeta:    meta
							context:      ctx
							resourceType: "namespace"
						}
					}
					metadata: name: namespaceSpec.name
					metadata: {
						if namespaceSpec.labels != _|_ {
							labels: namespaceSpec.labels
						}
						if namespaceSpec.annotations != _|_ {
							annotations: namespaceSpec.annotations
						}
					}
				},
			]
		}
	}
}
