package configuration

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ConfigMap is a kubernetes configmap resource with apiVersion and kind set to default values.
#ConfigMap: corev1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata:   metav1.#ObjectMeta
	#ConfigMapSpec
}

#ConfigMapSpec: {
	data?: [string]:       string
	binaryData?: [string]: bytes
	immutable?: bool
}
