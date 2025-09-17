package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// DaemonSet defines the properties and behaviors of a Kubernetes DaemonSet
#DaemonSet: core.#Trait & {
	#metadata: #traits: DaemonSet: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/apps/v1"
		#kind:       "DaemonSet"
		description: "Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod"
		domain:      "workload"
		scope: ["component"]

		provides: {daemonset: schema.#DaemonSetSpec}
	}
	daemonset: schema.#DaemonSetSpec
}

#DaemonSetMeta: #DaemonSet.#metadata.#traits.DaemonSet
