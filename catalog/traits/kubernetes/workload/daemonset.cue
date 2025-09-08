package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// DaemonSetTrait defines the properties and behaviors of a Kubernetes DaemonSet
#DaemonSetTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "DaemonSet"
	
	description: "Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/apps/v1.DaemonSet",
	]
	
	provides: {
		daemonset: schema.DaemonSetSpec
	}
}
#DaemonSet: core.#Trait & {
	#metadata: #traits: DaemonSet: #DaemonSetTrait
	daemonset: schema.DaemonSetSpec
}

// DaemonSetsTrait defines the properties and behaviors of multiple Kubernetes DaemonSets
#DaemonSetsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "DaemonSets"

	description: "Kubernetes DaemonSets ensure that all (or some) nodes run a copy of a pod"

	type:     "atomic"
	category: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/apps/v1.DaemonSet",
	]

	provides: {
		daemonsets: [string]: schema.DaemonSetSpec
	}
}
#DaemonSets: core.#Trait & {
	#metadata: #traits: DaemonSets: #DaemonSetsTrait
	daemonsets: [string]: schema.DaemonSetSpec
}
