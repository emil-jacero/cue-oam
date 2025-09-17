package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Secret defines the properties and behaviors of a Kubernetes Secret
#Secret: core.#Trait & {
	#metadata: #traits: Secret: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/core/v1"
		#kind:       "Secret"
		description: "Kubernetes Secret for storing sensitive configuration data"
		domain:      "data"
		scope: ["component"]
		provides: {secrets: [string]: schema.#SecretSpec}
	}
	secrets: [string]: schema.#SecretSpec
}

#SecretMeta: #Secret.#metadata.#traits.Secret
