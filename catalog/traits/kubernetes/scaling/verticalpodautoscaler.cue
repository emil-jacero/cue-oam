package scaling

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#VerticalPodAutoscalerTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "VerticalPodAutoscaler"
	
	description: "Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage"
	
	type:     "atomic"
	domain: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/autoscaling/v1.VerticalPodAutoscaler",
	]
	
	provides: {
		verticalpodautoscaler: schema.VerticalPodAutoscaler
	}
}
#VerticalPodAutoscaler: core.#Trait & {
	#metadata: #traits: VerticalPodAutoscaler: #VerticalPodAutoscalerTrait
	verticalpodautoscaler: schema.VerticalPodAutoscaler
}