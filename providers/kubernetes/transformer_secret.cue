package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Secret Transformer - Creates Secret resources
#SecretTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Secret"
	transform: {
		input:   trait.#Secret
		context: core.#ProviderContext
		output: {
			let secretSpec = input.secrets
			let meta = input.#metadata
			let ctx = context

			resources: [
				for secretName, secret in secretSpec {
					schema.#Secret & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(secretName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "secret"
							}
						}
						type: secret.type | *"Opaque"
						if secret.data != _|_ {
							data: secret.data
						}
						if secret.stringData != _|_ {
							stringData: secret.stringData
						}
					}
				},
			]
		}
	}
}
