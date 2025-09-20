package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Service Transformer - Creates Kubernetes Service resources
#ServiceTransformer: core.#Transformer & {
	creates: "k8s.io/api/core/v1.Service"

	required: [
		"core.oam.dev/v2alpha2.Expose",
	]

	optional: []

	// Default values for various traits.
	// These are automatically included for optional traits if not specified in the component.
	defaults: {...} // see #Transformer interface

	registry: trait.#TraitRegistry

	validates: {
		// This transformer processes components with Expose trait
	}

	transform: {
		component: core.#Component
		context:   core.#ProviderContext

		// Extract traits with CUE defaults
		let _expose = component.expose

		output: [
			schema.#Service & {
				metadata: #GenerateMetadata & {
					_input: {
						name:         component.#metadata.name
						traitMeta:    component.#metadata
						context:      context
						resourceType: "service"
					}
				}
				spec: {
					type: _expose.type

					ports: [
						for port in _expose.ports {
							{
								name:       port.name
								port:       port.exposedPort | port.targetPort
								targetPort: port.targetPort
								protocol:   port.protocol | *"TCP"
								if _expose.type == "NodePort" && port.nodePort != _|_ {
									nodePort: port.nodePort
								}
							}
						},
					]

					selector: {
						"app.kubernetes.io/name":     component.#metadata.name
						"app.kubernetes.io/instance": context.metadata.application.name
					}
				}
			},
		]
	}
}