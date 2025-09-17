package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ClusterRoleBinding defines the properties and behaviors of a Kubernetes ClusterRoleBinding
#ClusterRoleBinding: core.#Trait & {
	#metadata: #traits: ClusterRoleBinding: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/rbac/v1"
		#kind:       "ClusterRoleBinding"
		description: "Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide"
		domain:      "security"
		scope: ["component"]
		provides: {clusterrolebindings: [string]: schema.#ClusterRoleBindingSpec}
	}
	clusterrolebindings: [string]: schema.#ClusterRoleBindingSpec
}

#ClusterRoleBindingMeta: #ClusterRoleBinding.#metadata.#traits.ClusterRoleBinding
