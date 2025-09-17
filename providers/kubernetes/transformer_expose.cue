package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Expose Transformer - Creates Service for exposed ports
#ExposeTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Expose"
	transform: {
		input:   trait.#Expose
		context: core.#ProviderContext
		output: {
			let exposeSpec = input.expose
			let meta = input.#metadata
			let ctx = context

			resources: [
				// Service resource
				schema.#Service & {
					metadata: #GenerateMetadata & {
						_input: {
							name:         meta.name
							traitMeta:    meta
							context:      ctx
							resourceType: "service"
						}
					}
					spec: {
						// Service type
						if exposeSpec.type != _|_ {
							type: exposeSpec.type
						}
						if exposeSpec.type == _|_ {
							type: "ClusterIP"
						}

						// Selector
						if exposeSpec.selector != _|_ {
							selector: exposeSpec.selector
						}
						if exposeSpec.selector == _|_ {
							selector: {
								"app.kubernetes.io/name":     meta.name
								"app.kubernetes.io/instance": ctx.metadata.application.name
							}
						}

						// Ports
						if exposeSpec.ports != _|_ {
							ports: [
								for p in exposeSpec.ports {
									{
										if p.name != _|_ {
											name: p.name
										}
										if p.exposedPort != _|_ {
											port: p.exposedPort
										}
										if p.exposedPort == _|_ {
											port: p.containerPort
										}
										if p.targetPort != _|_ {
											targetPort: p.targetPort
										}
										if p.targetPort == _|_ {
											targetPort: p.exposedPort
										}
										if p.protocol != _|_ {
											protocol: p.protocol
										}

										// NodePort specific
										if (exposeSpec.type | *"ClusterIP") == "NodePort" && p.nodePort != _|_ {
											nodePort: p.nodePort
										}
									}
								},
							]
						}

						// LoadBalancer specific
						if (exposeSpec.type | *"ClusterIP") == "LoadBalancer" {
							if exposeSpec.loadBalancerIP != _|_ {
								loadBalancerIP: exposeSpec.loadBalancerIP
							}
							if exposeSpec.loadBalancerSourceRanges != _|_ {
								loadBalancerSourceRanges: exposeSpec.loadBalancerSourceRanges
							}
						}
					}
				},
			]
		}
	}
}
