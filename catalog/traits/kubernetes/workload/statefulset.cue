package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// StatefulSetTrait defines the properties and behaviors of a Kubernetes StatefulSet
#StatefulSetTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "StatefulSet"
	
	description: "Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage"
	
	type:     "atomic"
	domain: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/apps/v1.StatefulSet",
	]
	
	provides: {
		statefulset: schema.StatefulSetSpec
	}
}
#StatefulSet: core.#Trait & {
	#metadata: #traits: StatefulSet: #StatefulSetTrait
	statefulset: schema.StatefulSetSpec
}

// StatefulSetsTrait defines the properties and behaviors of multiple Kubernetes StatefulSets
#StatefulSetsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "StatefulSets"

	description: "Kubernetes StatefulSets for stateful workloads with stable network identities and persistent storage"

	type:     "atomic"
	domain: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/apps/v1.StatefulSet",
	]

	provides: {
		statefulsets: [string]: schema.StatefulSetSpec
	}
}
#StatefulSets: core.#Trait & {
	#metadata: #traits: StatefulSets: #StatefulSetsTrait
	statefulsets: [string]: schema.StatefulSetSpec
}
