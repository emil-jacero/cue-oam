package scaling

import (
	autoscalingv2 "cue.dev/x/k8s.io/api/autoscaling/v2"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// HorizontalPodAutoscaler is a kubernetes horizontalpodautoscaler resource with apiVersion and kind set to default values.
#HorizontalPodAutoscaler: autoscalingv2.#HorizontalPodAutoscaler & {
	apiVersion: "autoscaling/v2"
	kind:       "HorizontalPodAutoscaler"
	metadata:   metav1.#ObjectMeta
	spec?:      autoscalingv2.#HorizontalPodAutoscalerSpec
	status?:    autoscalingv2.#HorizontalPodAutoscalerStatus
}

#HorizontalPodAutoscalerSpec: autoscalingv2.#HorizontalPodAutoscalerSpec

#HorizontalPodAutoscalerStatus: autoscalingv2.#HorizontalPodAutoscalerStatus
