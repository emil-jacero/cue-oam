package security

import (
	rbacv1 "cue.dev/x/k8s.io/api/rbac/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Role is a kubernetes role resource with apiVersion and kind set to default values.
#Role: rbacv1.#Role & {
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata:   metav1.#ObjectMeta
	#RoleSpec
}

#PolicyRule: rbacv1.#PolicyRule

#RoleSpec: {
	rules?: [...rbacv1.#PolicyRule]
}
