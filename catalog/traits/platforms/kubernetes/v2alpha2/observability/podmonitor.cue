package observability

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// PodMonitor defines the properties and behaviors of a Kubernetes PodMonitor
#PodMonitor: core.#Trait & {
	#metadata: #traits: PodMonitor: core.#TraitMetaAtomic & {
		#apiVersion: "monitoring.coreos.com/v1"
		#kind:       "PodMonitor"
		description: "Prometheus PodMonitor for scraping metrics directly from pods"
		domain:      "observability"
		scope: ["component"]
		schema: {podmonitor: schema.#PodMonitorSpec}
	}
	podmonitor: schema.#PodMonitorSpec
}

#PodMonitorMeta: #PodMonitor.#metadata.#traits.PodMonitor
