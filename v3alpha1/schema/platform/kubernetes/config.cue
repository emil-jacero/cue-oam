package kubernetes

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#Config: corev1.#Config & {
	apiVersion: "v1"
	kind:       "Config"
	metadata:   metav1.#ObjectMeta
}
