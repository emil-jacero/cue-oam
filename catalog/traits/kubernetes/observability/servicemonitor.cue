package observability

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#ServiceMonitorTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ServiceMonitor"
	
	description: "Prometheus ServiceMonitor for scraping metrics from services"
	
	type:     "atomic"
	domain: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"monitoring.coreos.com/v1.ServiceMonitor",
	]
	
	provides: {
		servicemonitor: schema.ServiceMonitor
	}
}
#ServiceMonitor: core.#Trait & {
	#metadata: #traits: ServiceMonitor: #ServiceMonitorTrait
	servicemonitor: schema.ServiceMonitor
}
