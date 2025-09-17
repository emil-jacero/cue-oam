package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ClusterRole defines the properties and behaviors of a Kubernetes ClusterRole
#ClusterRole: core.#Trait & {
	#metadata: #traits: ClusterRole: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/rbac/v1"
		#kind:       "ClusterRole"
		description: "Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level"
		domain:      "security"
		scope: ["component"]
		provides: {clusterroles: [string]: schema.#ClusterRoleSpec}
	}
	clusterroles: [string]: schema.#ClusterRoleSpec
}

#ClusterRoleMeta: #ClusterRole.#metadata.#traits.ClusterRole
