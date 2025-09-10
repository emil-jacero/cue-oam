package v2alpha2

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/v2alpha2/schema"
)

//////////////////////////////////////////////
//// P0 - Critical Priority Scope Traits
//////////////////////////////////////////////

// NamespaceIsolationScope - Enforces namespace boundaries and isolation for all components within the scope
#NamespaceIsolationScopeTraitMeta: #NamespaceIsolationScope.#metadata.#traits.NamespaceIsolationScope

#NamespaceIsolationScope: core.#Trait & {
	#metadata: #traits: NamespaceIsolationScope: core.#TraitMetaAtomic & {
		#kind:       "NamespaceIsolationScope"
		description: "Enforces namespace boundaries and isolation for all components within the scope"
		domain:      "contractual"
		scope: ["scope"]
		provides: {namespaceIsolation: #NamespaceIsolationScope.namespaceIsolation}
	}

	namespaceIsolation: {
		// The namespace to isolate components in
		namespace: string

		// Isolation level
		isolationLevel: "strict" | "relaxed" | *"strict"

		// Cross-namespace communication rules
		crossNamespaceRules?: {
			// Allow ingress from specific namespaces
			allowIngressFrom?: [...string]

			// Allow egress to specific namespaces
			allowEgressTo?: [...string]

			// Block all cross-namespace traffic
			blockAll?: bool | *false
		}

		// Labels to apply to the namespace
		labels?: {[string]: string}

		// Annotations to apply to the namespace
		annotations?: {[string]: string}
	}
}

// SharedNetwork - Defines a shared network policy for all components in the scope
#SharedNetworkTraitMeta: #SharedNetwork.#metadata.#traits.SharedNetwork

#SharedNetwork: core.#Trait & {
	#metadata: #traits: SharedNetwork: core.#TraitMetaAtomic & {
		#kind:       "SharedNetwork"
		description: "Defines a shared network policy for all components in the scope"
		domain:      "structural"
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

// NamespaceQuota - Sets resource limits that apply to all components collectively within the namespace
#NamespaceQuotaTraitMeta: #NamespaceQuota.#metadata.#traits.NamespaceQuota

#NamespaceQuota: core.#Trait & {
	#metadata: #traits: NamespaceQuota: core.#TraitMetaAtomic & {
		#kind:       "NamespaceQuota"
		description: "Sets resource limits that apply to all components collectively within the namespace"
		domain:      "contractual"
		scope: ["scope"]
		provides: {namespaceQuota: #NamespaceQuota.namespaceQuota}
	}

	namespaceQuota: {
		// Resource quotas for the entire namespace
		resources: {
			// CPU limits
			cpu?: {
				requests?: schema.#CPUQuantity
				limits?:   schema.#CPUQuantity
			}

			// Memory limits
			memory?: {
				requests?: schema.#MemoryQuantity
				limits?:   schema.#MemoryQuantity
			}

			// Storage limits
			storage?: {
				requests?:               schema.#StorageQuantity
				persistentVolumeClaims?: uint
			}

			// GPU limits
			gpu?: {
				limits?: schema.#GPUQuantity
			}

			// Object count limits
			objects?: {
				pods?:                   uint
				services?:               uint
				configMaps?:             uint
				secrets?:                uint
				persistentVolumeClaims?: uint
				replicationControllers?: uint
			}
		}

		// Scope selector for applying quotas
		scopeSelector?: {
			matchLabels?: {[string]: string}
		}

		// Priority class for quota allocation
		priorityClass?: string
	}
}
