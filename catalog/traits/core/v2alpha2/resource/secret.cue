package resource

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Secret trait definition
// Describes a set of secrets
#SecretTraitMeta: #Secret.#metadata.#traits.Secret

#Secret: core.#Trait & {
	#metadata: #traits: Secret: core.#TraitMetaAtomic & {
		#kind:       "Secret"
		description: "Describes a set of secrets to be used by containers"
		domain:      "resource"
		scope: ["component"]
		provides: {secrets: #Secret.secrets}
	}

	// Secrets to be created
	secrets: [string]: schema.#SecretSpec
}