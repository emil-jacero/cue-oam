package kubernetes

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#PersistentVolumeClaim: corev1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata:   metav1.#ObjectMeta
	spec:       corev1.#PersistentVolumeClaimSpec
}

#PersistentVolumeClaimSpec: corev1.#PersistentVolumeClaimSpec

#PersistentVolume: corev1.#PersistentVolume & {
	apiVersion: "v1"
	kind:       "PersistentVolume"
	metadata:   metav1.#ObjectMeta
	spec:       corev1.#PersistentVolumeSpec
}

#PersistentVolumeSpec: corev1.#PersistentVolumeSpec
