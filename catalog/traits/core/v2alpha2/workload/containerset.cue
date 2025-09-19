package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// ContainerSet - Handles main containers and init containers
#ContainerSetMeta: #ContainerSet.#metadata.#traits.ContainerSet

#ContainerSet: core.#Trait & {
	#metadata: #traits: ContainerSet: core.#TraitMetaAtomic & {
		#kind:       "ContainerSet"
		description: "Container specification with main and init containers support"
		domain:      "workload"
		scope: ["component"]
		provides: containerSet: #ContainerSet.containerSet
	}

	containerSet: {
		// Ensure at least one main container is defined
		containers: main: {name: string | *#metadata.name}
		// Main containers (at least one required)
		containers: [string]: schema.#ContainerSpec

		// Optional init containers that run before main containers
		init?: [string]: schema.#ContainerSpec
	}
}
