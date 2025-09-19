package observability

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ServiceMonitor defines the properties and behaviors of a Kubernetes ServiceMonitor
#ServiceMonitor: core.#Trait & {
	#metadata: #traits: ServiceMonitor: core.#TraitMetaAtomic & {
		#apiVersion: "monitoring.coreos.com/v1"
		#kind:       "ServiceMonitor"
		description: "Prometheus ServiceMonitor for scraping metrics from services"
		domain:      "observability"
		scope: ["component"]
		schema: {servicemonitor: schema.#ServiceMonitorSpec}
	}
	servicemonitor: schema.#ServiceMonitorSpec
}

#ServiceMonitorMeta: #ServiceMonitor.#metadata.#traits.ServiceMonitor
