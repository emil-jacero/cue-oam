package v2alpha2

// Core traits organized by domain according to the 6 categories

import (
	// 1. Workload - Application runtime and execution models
	workload "jacero.io/oam/catalog/traits/core/v2alpha2/workload"

	// 2. Data - State management, configuration, and persistence
	data "jacero.io/oam/catalog/traits/core/v2alpha2/data"

	// 3. Connectivity - Networking, service discovery, and integration
	connectivity "jacero.io/oam/catalog/traits/core/v2alpha2/connectivity"

	// 4. Security - Protection, authentication, and authorization
	// security "jacero.io/oam/catalog/traits/core/v2alpha2/security"

	// 5. Observability - Monitoring, logging, tracing, and visibility
	// observability "jacero.io/oam/catalog/traits/core/v2alpha2/observability"

	// 6. Governance - Policies, constraints, and compliance
	governance "jacero.io/oam/catalog/traits/core/v2alpha2/governance"
)

// Export all traits for convenience

// Workload domain traits
#ContainerSet:   workload.#ContainerSet
#Replica:        workload.#Replica
#RestartPolicy:  workload.#RestartPolicy
#UpdateStrategy: workload.#UpdateStrategy
#Workload:       workload.#Workload
#Database:       workload.#Database

// Data domain traits
#Volume: data.#Volume
#Secret: data.#Secret
#Config: data.#Config

// Connectivity domain traits
#Expose:           connectivity.#Expose
#NetworkIsolation: connectivity.#NetworkIsolation
#SharedNetwork:    connectivity.#SharedNetwork

// Governance domain traits
#NamespaceQuota:     governance.#NamespaceQuota
#NamespaceIsolation: governance.#NamespaceIsolation
