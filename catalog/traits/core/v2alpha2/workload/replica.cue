package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Replica - Controls the number of instances
#ReplicaMeta: #Replica.#metadata.#traits.Replica

#Replica: core.#Trait & {
	#metadata: #traits: Replica: core.#TraitMetaAtomic & {
		#kind:       "Replica"
		description: "Specifies the number of replicas to run"
		domain:      "workload"
		scope: ["component"]
		// This trait modifies resources created by ContainerSet
		dependencies: [#ContainerSetMeta]
		provides: replica: #Replica.replica
	}

	replica: uint | *1
}
