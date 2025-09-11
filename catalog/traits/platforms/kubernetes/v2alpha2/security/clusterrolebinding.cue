package security

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// ClusterRoleBindingTrait defines the properties and behaviors of a Kubernetes ClusterRoleBinding
#ClusterRoleBindingTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ClusterRoleBinding"

	description: "Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide"

	type:   "atomic"
	domain: "security"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/rbac/v1.ClusterRoleBinding",
	]

	provides: {
		clusterrolebinding: schema.ClusterRoleBinding
	}
}
#ClusterRoleBinding: core.#Trait & {
	#metadata: #traits: ClusterRoleBinding: #ClusterRoleBindingTrait
	clusterrolebinding: schema.ClusterRoleBinding
}

// ClusterRoleBindingsTrait defines the properties and behaviors of multiple Kubernetes ClusterRoleBindings
#ClusterRoleBindingsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ClusterRoleBindings"

	description: "Kubernetes ClusterRoleBindings grants permissions defined in a ClusterRole to a user or set of users cluster-wide"

	type:   "atomic"
	domain: "security"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/rbac/v1.ClusterRoleBinding",
	]

	provides: {
		clusterrolebindings: [string]: schema.ClusterRoleBinding
	}
}
#ClusterRoleBindings: core.#Trait & {
	#metadata: #traits: ClusterRoleBindings: #ClusterRoleBindingsTrait
	clusterrolebindings: [string]: schema.ClusterRoleBinding
}
