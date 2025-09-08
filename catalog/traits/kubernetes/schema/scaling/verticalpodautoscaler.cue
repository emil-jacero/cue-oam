package scaling

import (
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// VerticalPodAutoscaler is a kubernetes verticalpodautoscaler resource with apiVersion and kind set to default values.
// Note: VPA is not part of core k8s.io schemas, so we define basic structure
#VerticalPodAutoscaler: {
	apiVersion: "autoscaling.k8s.io/v1"
	kind:       "VerticalPodAutoscaler"
	metadata:   metav1.#ObjectMeta
	spec?:      #VerticalPodAutoscalerSpec
	status?:    #VerticalPodAutoscalerStatus
}

#VerticalPodAutoscalerSpec: {
	targetRef: {
		apiVersion: string
		kind:       string
		name:       string
	}
	updatePolicy?: {
		updateMode?: "Off" | "Initial" | "Recreate" | "Auto"
	}
	resourcePolicy?: {
		containerPolicies?: [...{
			containerName?: string
			mode?:          "Off" | "Auto"
			minAllowed?: [string]: string
			maxAllowed?: [string]: string
			controlledResources?: [...string]
			controlledValues?: "RequestsAndLimits" | "RequestsOnly"
		}]
	}
}

#VerticalPodAutoscalerStatus: {
	lastUpdateTime?: string
	recommendation?: {
		containerRecommendations?: [...{
			containerName?: string
			target?: [string]:         string
			lowerBound?: [string]:     string
			upperBound?: [string]:     string
			uncappedTarget?: [string]: string
		}]
	}
	conditions?: [...{
		type:               string
		status:             "True" | "False" | "Unknown"
		lastTransitionTime: string
		reason?:            string
		message?:           string
	}]
}
