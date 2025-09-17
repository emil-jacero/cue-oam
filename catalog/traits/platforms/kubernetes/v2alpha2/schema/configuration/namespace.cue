package configuration

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Namespace is a kubernetes namespace resource with apiVersion and kind set to default values.
#Namespace: corev1.#Namespace & {
	apiVersion: "v1"
	kind:       "Namespace"
	metadata:   metav1.#ObjectMeta
}
