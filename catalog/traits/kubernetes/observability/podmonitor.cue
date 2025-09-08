package observability

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#PodMonitorTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "PodMonitor"
	
	description: "Prometheus PodMonitor for scraping metrics directly from pods"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"monitoring.coreos.com/v1.PodMonitor",
	]
	
	provides: {
		podmonitor: schema.PodMonitor
	}
}
#PodMonitor: core.#Trait & {
	#metadata: #traits: PodMonitor: #PodMonitorTrait
	podmonitor: schema.PodMonitor
}
