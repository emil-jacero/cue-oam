package contractual

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

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