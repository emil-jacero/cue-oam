package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// StatefulSet defines the properties and behaviors of a Kubernetes StatefulSet
#StatefulSet: core.#Trait & {
	#metadata: #traits: StatefulSet: core.#TraitMetaAtomic & {
		#kind:       "StatefulSet"
		description: "Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage"
		domain:      "workload"
		scope: ["component"]
		provides: {statefulset: schema.#StatefulSetSpec}
	}
	statefulset: schema.#StatefulSetSpec
}

#StatefulSetMeta: #StatefulSet.#metadata.#traits.StatefulSet
