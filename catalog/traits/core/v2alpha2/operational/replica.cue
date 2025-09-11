package operational

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Replica - Controls the number of instances
#ReplicaTraitMeta: #Replica.#metadata.#traits.Replica

#Replica: core.#Trait & {
	#metadata: #traits: Replica: core.#TraitMetaAtomic & {
		#kind:       "Replica"
		description: "Specifies the number of replicas to run"
		domain:      "operational"
		scope: ["component"]
		// This trait modifies resources created by ContainerSet
		dependencies: [#ContainerSetTraitMeta]
		provides: {replica: #Replica.replica}
	}

	replica: {
		count: uint | *1
	}
}