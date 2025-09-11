package storage

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	storagev1 "cue.dev/x/k8s.io/api/storage/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// StorageClass is a kubernetes storageclass resource with apiVersion and kind set to default values.
#StorageClass: storagev1.#StorageClass & {
	apiVersion:            "storage.k8s.io/v1"
	kind:                  "StorageClass"
	metadata:              metav1.#ObjectMeta
	allowVolumeExpansion?: bool
	allowedTopologies?: [storagev1.#TopologySelectorTerm]
}

#TopologySelectorTerm: corev1.#TopologySelectorTerm
