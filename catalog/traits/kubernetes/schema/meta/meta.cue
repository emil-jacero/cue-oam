package meta

import (
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

#Object: {
	metadata: metav1.#ObjectMeta
	...
}

#ObjectMeta: metav1.#ObjectMeta
