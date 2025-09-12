package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// HorizontalPodAutoscaler defines the properties and behaviors of a Kubernetes HorizontalPodAutoscaler
#HorizontalPodAutoscaler: core.#Trait & {
	#metadata: #traits: HorizontalPodAutoscaler: core.#TraitMetaAtomic & {
		#kind:       "HorizontalPodAutoscaler"
		description: "Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics"
		domain:      "workload"
		scope: ["component"]
		provides: {horizontalpodautoscaler: schema.#HorizontalPodAutoscalerSpec}
	}
	horizontalpodautoscaler: schema.#HorizontalPodAutoscalerSpec
}

#HorizontalPodAutoscalerMeta: #HorizontalPodAutoscaler.#metadata.#traits.HorizontalPodAutoscaler
