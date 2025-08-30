package kubernetes

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#Secret: corev1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   metav1.#ObjectMeta
}
