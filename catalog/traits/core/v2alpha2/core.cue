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
	// governance "jacero.io/oam/catalog/traits/core/v2alpha2/governance"
)

// Export all traits for convenience

// Workload domain traits
#ContainerSet:   workload.#ContainerSet
#ContainerSetMeta: workload.#ContainerSetMeta
#Replicas:        workload.#Replicas
#ReplicasMeta:     workload.#ReplicasMeta
#RestartPolicy:  workload.#RestartPolicy
#RestartPolicyMeta: workload.#RestartPolicyMeta
#UpdateStrategy: workload.#UpdateStrategy
#UpdateStrategyMeta: workload.#UpdateStrategyMeta
#Workload:       workload.#Workload
#WorkloadMeta:    workload.#WorkloadMeta
#Database:       workload.#Database
#DatabaseMeta:    workload.#DatabaseMeta

// Data domain traits
#Volume: data.#Volume
#VolumeMeta: data.#VolumeMeta
#Secret: data.#Secret
#SecretMeta: data.#SecretMeta
#Config: data.#Config
#ConfigMeta: data.#ConfigMeta

// Connectivity domain traits
#Expose:           connectivity.#Expose
#ExposeMeta:        connectivity.#ExposeMeta
#NetworkIsolation: connectivity.#NetworkIsolation
#NetworkIsolationMeta: connectivity.#NetworkIsolationMeta
#SharedNetwork:    connectivity.#SharedNetwork
#SharedNetworkMeta: connectivity.#SharedNetworkMeta

// Governance domain traits

// Export registration entry for the trait registry
#TraitRegistry: [
	#WorkloadMeta,
	#ContainerSetMeta,
	#ReplicasMeta,
	#RestartPolicyMeta,
	#UpdateStrategyMeta,
	#DatabaseMeta,
	#VolumeMeta,
	#SecretMeta,
	#ConfigMeta,
	#ExposeMeta,
	#NetworkIsolationMeta,
	#SharedNetworkMeta,
	...
]
