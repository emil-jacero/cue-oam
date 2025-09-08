package scaling

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#HorizontalPodAutoscalerTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "HorizontalPodAutoscaler"
	
	description: "Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/autoscaling/v2.HorizontalPodAutoscaler",
	]
	
	provides: {
		horizontalpodautoscaler: schema.HorizontalPodAutoscaler
	}
}
#HorizontalPodAutoscaler: core.#Trait & {
	#metadata: #traits: HorizontalPodAutoscaler: #HorizontalPodAutoscalerTrait
	horizontalpodautoscaler: schema.HorizontalPodAutoscaler
}
