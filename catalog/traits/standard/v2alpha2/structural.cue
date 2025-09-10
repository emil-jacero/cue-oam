package v2alpha2

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/v2alpha2/schema"
)

// Expose - Marks a component as exposable for external access
#ExposeTraitMeta: #Expose.#metadata.#traits.Expose

#Expose: core.#Trait & {
	#metadata: #traits: Expose: core.#TraitMetaAtomic & {
		#kind:       "Expose"
		description: "Marks a component as exposable for external access"
		domain:      "structural"
		scope: ["component"]
		provides: {expose: #Expose.expose}
	}

	expose: {
		// Type of service to create
		type: "LoadBalancer" | "NodePort" | "ClusterIP" | *"ClusterIP"
		// Port mappings
		ports: [...schema.#Port]
	}
}

// Network Isolation Scope - manages network boundaries and policies
#NetworkIsolationScopeTraitMeta: #NetworkIsolationScope.#metadata.#traits.NetworkIsolationScope

#NetworkIsolationScope: core.#Trait & {
	#metadata: #traits: NetworkIsolationScope: core.#TraitMetaAtomic & {
		#kind:       "NetworkIsolationScope"
		description: "Manages network boundaries for components or scopes"
		domain:      "structural"
		scope: ["scope"]
		provides: {network: #NetworkIsolationScope.network}
	}

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
