package workload

import (
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// DaemonSet is a kubernetes daemonset resource with apiVersion and kind set to default values.
#DaemonSet: appsv1.#DaemonSet & {
	apiVersion: "apps/v1"
	kind:       "DaemonSet"
	metadata:   metav1.#ObjectMeta
	spec?:      appsv1.#DaemonSetSpec
	status?:    appsv1.#DaemonSetStatus
}

#DaemonSetSpec: appsv1.#DaemonSetSpec

#DaemonSetStatus: appsv1.#DaemonSetStatus
