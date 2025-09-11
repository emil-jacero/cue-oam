package v2alpha2

// Core traits organized by domain according to the 8 categories

import (
	// 1. Operational - How things execute (runtime behavior)
	operational "jacero.io/oam/catalog/traits/core/v2alpha2/operational"

	// 2. Structural - How things are organized and related
	structural "jacero.io/oam/catalog/traits/core/v2alpha2/structural"

	// 3. Behavioral - How things act and react (logic and patterns)
	// behavioral "jacero.io/oam/catalog/traits/core/v2alpha2/behavioral"

	// 4. Resource - What things have and need (state and data)
	resource "jacero.io/oam/catalog/traits/core/v2alpha2/resource"

	// 5. Contractual - What things must guarantee (constraints and policies)
	contractual "jacero.io/oam/catalog/traits/core/v2alpha2/contractual"

	// 6. Security - How things are protected and controlled
	// security "jacero.io/oam/catalog/traits/core/v2alpha2/security"

	// 7. Observability - How things are monitored and understood
	// observability "jacero.io/oam/catalog/traits/core/v2alpha2/observability"

	// 8. Integration - How things connect and communicate
	// integration "jacero.io/oam/catalog/traits/core/v2alpha2/integration"
)

// Export all traits for convenience
#ContainerSet:   operational.#ContainerSet
#Replica:        operational.#Replica
#RestartPolicy:  operational.#RestartPolicy
#UpdateStrategy: operational.#UpdateStrategy

#Expose:                  structural.#Expose
#NetworkIsolationScope:   structural.#NetworkIsolationScope
#NamespaceIsolationScope: structural.#NamespaceIsolationScope
#SharedNetwork:           structural.#SharedNetwork

#Volume: resource.#Volume
#Secret: resource.#Secret
#Config: resource.#Config

#NamespaceQuota: contractual.#NamespaceQuota
