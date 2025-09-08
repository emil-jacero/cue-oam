package standard

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Network Isolation Scope - manages network boundaries and policies
#NetworkIsolationScope: core.#Trait & {
	#metadata: #traits: NetworkIsolationScope: #NetworkIsolationScopeTrait

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
#NetworkIsolationScopeTrait: core.#TraitObject & {
	#kind:    "NetworkIsolationScope"
	type:     "atomic"
	category: "structural"
	scope: ["component", "scope"]
	requiredCapabilities: [
		"k8s.io/api/networking/v1.NetworkPolicy",
	]
	provides: {network: #NetworkIsolationScope.network}
}
