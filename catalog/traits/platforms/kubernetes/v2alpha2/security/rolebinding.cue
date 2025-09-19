package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// RoleBinding defines the properties and behaviors of a Kubernetes RoleBinding
#RoleBinding: core.#Trait & {
	#metadata: #traits: RoleBinding: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/rbac/v1"
		#kind:       "RoleBinding"
		description: "Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users"
		domain:      "security"
		scope: ["component"]
		schema: {rolebindings: [string]: schema.#RoleBindingSpec}
	}
	rolebindings: [string]: schema.#RoleBindingSpec
}

#RoleBindingMeta: #RoleBinding.#metadata.#traits.RoleBinding
