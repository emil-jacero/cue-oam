package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Network Isolation - manages network boundaries and policies
#NetworkIsolationMeta: #NetworkIsolation.#metadata.#traits.NetworkIsolation

#NetworkIsolation: core.#Trait & {
	#metadata: #traits: NetworkIsolation: core.#TraitMetaAtomic & {
		#kind:       "NetworkIsolation"
		description: "Manages network boundaries for components or scopes"
		domain:      "connectivity"
		scope: ["scope"]
		provides: {network: #NetworkIsolation.network}
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
