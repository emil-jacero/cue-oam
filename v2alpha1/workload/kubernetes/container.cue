package kubernetes

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#Pod: corev1.#Pod & {
	apiVersion: "v1"
	kind:       "Pod"
	metadata:   metav1.#ObjectMeta
	spec?:      corev1.#PodSpec
	status?:    corev1.#PodStatus
}

#PodSpec: corev1.#PodSpec

#PodStatus: corev1.#PodStatus

#Container: corev1.#Container

#ContainerPort: corev1.#ContainerPort
