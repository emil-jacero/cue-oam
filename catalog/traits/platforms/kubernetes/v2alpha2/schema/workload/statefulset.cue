package workload

import (
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// StatefulSet is a kubernetes statefulset resource with apiVersion and kind set to default values.
#StatefulSet: appsv1.#StatefulSet & {
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata:   metav1.#ObjectMeta
	spec?:      appsv1.#StatefulSetSpec
	status?:    appsv1.#StatefulSetStatus
}

#StatefulSetSpec: appsv1.#StatefulSetSpec

#StatefulSetStatus: appsv1.#StatefulSetStatus
