package structural

import (
	core "jacero.io/oam/core/v2alpha2"
)

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