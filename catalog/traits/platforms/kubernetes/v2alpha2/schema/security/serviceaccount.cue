package security

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ServiceAccount is a kubernetes serviceaccount resource with apiVersion and kind set to default values.
#ServiceAccount: corev1.#ServiceAccount & {
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   metav1.#ObjectMeta
	secrets?: [...corev1.#ObjectReference]
	imagePullSecrets?: [...corev1.#LocalObjectReference]
	automountServiceAccountToken?: bool
}
