package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// SharedNetwork - Defines a shared network policy for all components in the scope
#SharedNetworkMeta: #SharedNetwork.#metadata.#traits.SharedNetwork

#SharedNetwork: core.#Trait & {
	#metadata: #traits: SharedNetwork: core.#TraitMetaAtomic & {
		#kind:       "SharedNetwork"
		description: "Defines a shared network policy for all components in the scope"
		domain:      "connectivity"
		scope: ["scope"]
		provides: {sharedNetwork: #SharedNetwork.sharedNetwork}
	}

	sharedNetwork: {
		// Network configuration that applies to all components
		networkConfig: {
			// DNS policy for the scope
			dnsPolicy?: "ClusterFirst" | "ClusterFirstWithHostNet" | "Default" | "None" | *"ClusterFirst"

			// Custom DNS configuration
			dnsConfig?: {
				nameservers?: [...string]
				searches?: [...string]
				options?: [...{
					name:   string
					value?: string
				}]
			}

			// Service mesh integration
			serviceMesh?: {
				enabled:   bool | *false
				provider?: "istio" | "linkerd" | "consul"
				settings?: {...}
			}

			// Network policies that apply to all components
			policies?: [...{
				name: string
				type: "ingress" | "egress"

				// Allow/deny rules
				rules?: [...{
					action: "allow" | "deny"

					// Source/destination selectors
					from?: {
						namespaceSelector?: {[string]: string}
						podSelector?: {[string]: string}
						ipBlock?: {
							cidr: string
							except?: [...string]
						}
					}
					to?: {
						namespaceSelector?: {[string]: string}
						podSelector?: {[string]: string}
						ipBlock?: {
							cidr: string
							except?: [...string]
						}
					}

					// Port specifications
					ports?: [...schema.#Port]
				}]
			}]
		}

		// Internal service discovery configuration
		serviceDiscovery?: {
			enabled: bool | *true
			type:    "dns" | "environment" | *"dns"

			// Service naming pattern
			namingPattern?: string | *"{{.service}}.{{.namespace}}.svc.cluster.local"
		}
	}
}
