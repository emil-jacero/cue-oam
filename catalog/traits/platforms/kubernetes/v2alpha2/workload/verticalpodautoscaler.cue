package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// VerticalPodAutoscaler defines the properties and behaviors of a Kubernetes VerticalPodAutoscaler
#VerticalPodAutoscaler: core.#Trait & {
	#metadata: #traits: VerticalPodAutoscaler: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/autoscaling/v1"
		#kind:       "VerticalPodAutoscaler"
		description: "Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage"
		domain:      "workload"
		scope: ["component"]
		provides: {verticalpodautoscaler: schema.#VerticalPodAutoscaler}
	}
	verticalpodautoscaler: schema.#VerticalPodAutoscaler
}

#VerticalPodAutoscalerMeta: #VerticalPodAutoscaler.#metadata.#traits.VerticalPodAutoscaler
