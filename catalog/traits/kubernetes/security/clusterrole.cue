package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// ClusterRoleTrait defines the properties and behaviors of a Kubernetes ClusterRole
#ClusterRoleTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ClusterRole"
	
	description: "Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level"
	
	type:     "atomic"
	domain: "behavioral"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.ClusterRole",
	]
	
	provides: {
		clusterrole: schema.ClusterRole
	}
}
#ClusterRole: core.#Trait & {
	#metadata: #traits: ClusterRole: #ClusterRoleTrait
	clusterrole: schema.ClusterRole
}

// ClusterRolesTrait defines the properties and behaviors of multiple Kubernetes ClusterRoles
#ClusterRolesTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ClusterRoles"

	description: "Kubernetes ClusterRoles contains rules that represent a set of permissions at the cluster level"

	type:     "atomic"
	domain: "behavioral"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/rbac/v1.ClusterRole",
	]

	provides: {
		clusterroles: [string]: schema.ClusterRole
	}
}
#ClusterRoles: core.#Trait & {
	#metadata: #traits: ClusterRoles: #ClusterRolesTrait
	clusterroles: [string]: schema.ClusterRole
}
