package security

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// RoleBinding is a kubernetes rolebinding resource with apiVersion and kind set to default values.
#RoleBinding: rbacv1.#RoleBinding & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata:   metav1.#ObjectMeta
	#RoleBindingSpec
}

#Subject: rbacv1.#Subject

#RoleRef: rbacv1.#RoleRef

#RoleBindingSpec: {
	subjects?: [...rbacv1.#Subject]
	roleRef: rbacv1.#RoleRef
}
