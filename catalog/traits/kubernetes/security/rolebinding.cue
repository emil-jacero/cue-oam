package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// RoleBindingTrait defines the properties and behaviors of a Kubernetes RoleBinding
#RoleBindingTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "RoleBinding"
	
	description: "Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users"
	
	type:     "atomic"
	category: "behavioral"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.RoleBinding",
	]
	
	provides: {
		rolebinding: schema.RoleBinding
	}
}
#RoleBinding: core.#Trait & {
	#metadata: #traits: RoleBinding: #RoleBindingTrait
	rolebinding: schema.RoleBinding
}

// RoleBindingsTrait defines the properties and behaviors of multiple Kubernetes RoleBindings
#RoleBindingsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "RoleBindings"

	description: "Kubernetes RoleBindings grants permissions defined in a Role to a user or set of users"

	type:     "atomic"
	category: "behavioral"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/rbac/v1.RoleBinding",
	]

	provides: {
		rolebindings: [string]: schema.RoleBinding
	}
}
#RoleBindings: core.#Trait & {
	#metadata: #traits: RoleBindings: #RoleBindingsTrait
	rolebindings: [string]: schema.RoleBinding
}
