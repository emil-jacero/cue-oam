package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Role defines the properties and behaviors of a Kubernetes Role
#Role: core.#Trait & {
	#metadata: #traits: Role: core.#TraitMetaAtomic & {
		#kind:       "Role"
		description: "Kubernetes Role contains rules that represent a set of permissions within a namespace"
		domain:      "security"
		scope: ["component"]
		provides: {roles: [string]: schema.#RoleSpec}
	}
	roles: [string]: schema.#RoleSpec
}

#RoleMeta: #Role.#metadata.#traits.Role
