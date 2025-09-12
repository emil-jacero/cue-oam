package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ServiceAccount defines the properties and behaviors of a Kubernetes ServiceAccount
#ServiceAccount: core.#Trait & {
	#metadata: #traits: ServiceAccount: core.#TraitMetaAtomic & {
		#kind:       "ServiceAccount"
		description: "Kubernetes ServiceAccount provides an identity for processes that run in a Pod"
		domain:      "data"
		scope: ["component"]
		provides: {serviceaccounts: [string]: schema.#ServiceAccountSpec}
	}
	serviceaccounts: [string]: schema.#ServiceAccountSpec
}

#ServiceAccountMeta: #ServiceAccount.#metadata.#traits.ServiceAccount
