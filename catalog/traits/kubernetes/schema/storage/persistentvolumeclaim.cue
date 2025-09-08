package storage

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// PersistentVolumeClaim is a kubernetes persistentvolumeclaim resource with apiVersion and kind set to default values.
#PersistentVolumeClaim: corev1.#PersistentVolumeClaim & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata:   metav1.#ObjectMeta
	spec?:      corev1.#PersistentVolumeClaimSpec
	status?:    corev1.#PersistentVolumeClaimStatus
}

#PersistentVolumeClaimSpec: corev1.#PersistentVolumeClaimSpec

#PersistentVolumeClaimStatus: corev1.#PersistentVolumeClaimStatus
