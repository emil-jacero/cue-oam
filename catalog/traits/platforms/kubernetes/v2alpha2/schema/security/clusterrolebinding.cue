package security

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ClusterRoleBinding is a kubernetes clusterrolebinding resource with apiVersion and kind set to default values.
#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata:   metav1.#ObjectMeta
	subjects?: [...rbacv1.#Subject]
	roleRef: rbacv1.#RoleRef
}
