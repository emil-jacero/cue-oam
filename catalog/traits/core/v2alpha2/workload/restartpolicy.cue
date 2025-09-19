package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// RestartPolicy - Controls restart behavior
#RestartPolicyMeta: #RestartPolicy.#metadata.#traits.RestartPolicy

#RestartPolicy: core.#Trait & {
	#metadata: #traits: RestartPolicy: core.#TraitMetaAtomic & {
		#kind:       "RestartPolicy"
		description: "Defines restart behavior for containers"
		domain:      "workload"
		scope: ["component"]
		// This trait modifies Pod spec created by ContainerSet
		dependencies: [#ContainerSetMeta]
		provides: restartPolicy: #RestartPolicy.restartPolicy
	}

	restartPolicy: string | *"Always" | "OnFailure" | "Never"
}
