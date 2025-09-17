package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Config Transformer - Creates ConfigMap resources
#ConfigTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Config"
	transform: {
		input:   trait.#Config
		context: core.#ProviderContext
		output: {
			let configSpec = input.configMap
			let meta = input.#metadata
			let ctx = context

			resources: [
				for configName, config in configSpec {
					schema.#ConfigMap & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(configName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "configmap"
							}
						}
						if config.data != _|_ {
							data: config.data
						}
						if config.binaryData != _|_ {
							binaryData: config.binaryData
						}
					}
				},
			]
		}
	}
}
