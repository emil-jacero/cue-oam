package security

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ClusterRole is a kubernetes clusterrole resource with apiVersion and kind set to default values.
#ClusterRole: rbacv1.#ClusterRole & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata:   metav1.#ObjectMeta
	#ClusterRoleSpec
}

#AggregationRule: rbacv1.#AggregationRule

#ClusterRoleSpec: {
	rules?: [...rbacv1.#PolicyRule]
	aggregationRule?: rbacv1.#AggregationRule
}
