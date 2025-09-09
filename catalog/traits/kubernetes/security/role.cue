package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// RoleTrait defines the properties and behaviors of a Kubernetes Role
#RoleTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Role"
	
	description: "Kubernetes Role contains rules that represent a set of permissions within a namespace"
	
	type:     "atomic"
	domain: "behavioral"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.Role",
	]
	
	provides: {
		role: schema.Role
	}
}
#Role: core.#Trait & {
	#metadata: #traits: Role: #RoleTrait
	role: schema.Role
}

// Roles defines the properties and behaviors of multiple Kubernetes Roles
#RolesTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Roles"

	description: "Kubernetes Roles contains rules that represent a set of permissions within a namespace"

	type:     "atomic"
	domain: "behavioral"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/rbac/v1.Role",
	]

	provides: {
		roles: [string]: schema.Role
	}
}
#Roles: core.#Trait & {
	#metadata: #traits: Roles: #RolesTrait
	roles: [string]: schema.Role
}