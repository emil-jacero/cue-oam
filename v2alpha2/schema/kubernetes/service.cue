package kubernetes

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#Service: corev1.#Service & {
	apiVersion: "v1"
	kind:       "Service"
	metadata:   metav1.#ObjectMeta
	spec?:      corev1.#ServiceSpec
	status?:    corev1.#ServiceStatus
}

#ServiceSpec: corev1.#ServiceSpec

#ServiceStatus: corev1.#ServiceStatus
