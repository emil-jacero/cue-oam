package standard

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/schema"
)

// Expose - Marks a component as exposable for external access
#ExposeTraitMeta: core.#TraitMeta & {
	#kind:    "Expose"
	description: "Marks a component as exposable for external access"
	type:     "atomic"
	domain: "structural"
	scope:    ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha2.Expose",
	]
	provides: {
		expose: {
			// Type of service to create
			type: "LoadBalancer" | "NodePort" | "ClusterIP" | *"ClusterIP"
			// Port mappings
			ports: [...schema.#Port]
		}
	}
}
#Expose: core.#Trait & {
	#metadata: #traits: Expose: #ExposeTraitMeta

	expose: #ExposeTraitMeta.provides.expose
}

// Network Isolation Scope - manages network boundaries and policies
#NetworkIsolationScopeTraitMeta: core.#TraitMeta & {
	#kind:    "NetworkIsolationScope"
	type:     "atomic"
	domain: "structural"
	scope: ["component", "scope"]
	requiredCapabilities: [
		"k8s.io/api/networking/v1.NetworkPolicy",
	]
	provides: {
		network: {
			isolation: "none" | "namespace" | "pod" | "strict" | *"namespace"
			policies?: [...{
				scope: "ingress" | "egress"
				from?: [...{
					namespaceSelector?: {...}
					podSelector?: {...}
					ipBlock?: {cidr: string}
				}]
				to?: [...{
					namespaceSelector?: {...}
					podSelector?: {...}
					ipBlock?: {cidr: string}
				}]
				ports?: [...{
					protocol: "TCP" | "UDP" | "SCTP"
					port:     int | string
				}]
			}]
		}
	}
}
#NetworkIsolationScope: core.#Trait & {
	#metadata: #traits: NetworkIsolationScope: #NetworkIsolationScopeTraitMeta

	network: #NetworkIsolationScopeTraitMeta.provides.network
}
