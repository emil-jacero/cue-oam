package workload

import (
	appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	// corev1 "cue.dev/x/k8s.io/api/core/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Deployment is a kubernetes deployment resources with apiVersion and kind set to default values.
#Deployment: appsv1.#Deployment & {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   metav1.#ObjectMeta
	spec?:      appsv1.#DeploymentSpec
	status?:    appsv1.#DeploymentStatus
}

#DeploymentSpec: appsv1.#DeploymentSpec

#DeploymentStatus: appsv1.#DeploymentStatus
