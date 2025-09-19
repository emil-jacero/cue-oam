package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Secret trait definition
// Describes a set of secrets
#SecretMeta: #Secret.#metadata.#traits.Secret

#Secret: core.#Trait & {
	#metadata: #traits: Secret: core.#TraitMetaAtomic & {
		#kind:       "Secret"
		description: "Describes a set of secrets to be used by containers"
		domain:      "data"
		scope: ["component"]
		provides: secrets: [string]: schema.#SecretSpec
	}

	// Secrets to be created
	secrets: [string]: schema.#SecretSpec & {
		type: schema.#SecretSpec.type
		if type == "kubernetes.io/dockerconfigjson" {
			data: ".dockerconfigjson":        string
			stringData?: ".dockerconfigjson": string
		}
		if type == "kubernetes.io/ssh-auth" {
			data: "ssh-privatekey":        string
			stringData?: "ssh-privatekey": string
		}
		if type == "kubernetes.io/tls" {
			data: "tls.crt":        string
			data: "tls.key":        string
			stringData?: "tls.crt": string
			stringData?: "tls.key": string
		}
	}
}
