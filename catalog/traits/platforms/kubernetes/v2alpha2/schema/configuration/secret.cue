package configuration

import (
	corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Secret is a kubernetes secret resource with apiVersion and kind set to default values.
#Secret: corev1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   metav1.#ObjectMeta
	#SecretSpec
}

#SecretSpec: {
	type?: corev1.#SecretType
	data?: [string]:       bytes
	stringData?: [string]: string
	immutable?: bool
}
