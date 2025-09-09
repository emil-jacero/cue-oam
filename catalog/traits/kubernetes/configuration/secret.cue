package configuration

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#SecretsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Secrets"

	description: "Kubernetes Secrets for storing sensitive configuration data"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.Secret",
	]

	provides: {
		secrets: [string]: schema.Secret
	}
}
#Secrets: core.#Trait & {
	#metadata: #traits: Secrets: #SecretsTrait
	secrets: [string]: schema.Secret
}

#SecretTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Secret"

	description: "Kubernetes Secret for storing sensitive configuration data"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.Secret",
	]

	provides: {
		secret: schema.Secret
	}
}
#Secret: core.#Trait & {
	#metadata: #traits: Secrets: #SecretsTrait
	secret: schema.Secret
}
