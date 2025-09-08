package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// ServiceAccountTrait defines the properties and behaviors of a Kubernetes ServiceAccount
#ServiceAccountTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ServiceAccount"
	
	description: "Kubernetes ServiceAccount provides an identity for processes that run in a Pod"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.ServiceAccount",
	]
	
	provides: {
		serviceaccount: schema.ServiceAccount
	}
}
#ServiceAccount: core.#Trait & {
	#metadata: #traits: ServiceAccount: #ServiceAccountTrait
	serviceaccount: schema.ServiceAccount
}

// ServiceAccounts defines the properties and behaviors of multiple Kubernetes ServiceAccounts
#ServiceAccountsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ServiceAccounts"

	description: "Kubernetes ServiceAccounts provides an identity for processes that run in a Pod"

	type:     "atomic"
	category: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.ServiceAccount",
	]

	provides: {
		serviceaccounts: [string]: schema.ServiceAccount
	}
}
#ServiceAccounts: core.#Trait & {
	#metadata: #traits: ServiceAccounts: #ServiceAccountsTrait
	serviceaccounts: [string]: schema.ServiceAccount
}
