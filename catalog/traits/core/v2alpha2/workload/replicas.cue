package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Replica - Controls the number of instances
#ReplicasMeta: #Replicas.#metadata.#traits.Replicas

#Replicas: core.#Trait & {
	#metadata: #traits: Replicas: core.#TraitMetaAtomic & {
		#kind:       "Replicas"
		description: "Specifies the number of replicas to run"
		domain:      "workload"
		scope: ["component"]
		schema: replicas: #ReplicasSchema
	}

	replicas: #ReplicasSchema
}

#ReplicasSchema: uint | *1
