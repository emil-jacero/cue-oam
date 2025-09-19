package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// UpdateStrategy - Controls how updates are applied
#UpdateStrategyMeta: #UpdateStrategy.#metadata.#traits.UpdateStrategy

#UpdateStrategy: core.#Trait & {
	#metadata: #traits: UpdateStrategy: core.#TraitMetaAtomic & {
		#kind:       "UpdateStrategy"
		description: "Defines how updates are applied to running instances"
		domain:      "workload"
		scope: ["component"]
		schema: updateStrategy: #UpdateStrategySchema
	}

	updateStrategy: #UpdateStrategySchema & {
		type: *"RollingUpdate" | "Recreate"

		// Only applicable when type is "RollingUpdate"
		rollingUpdate?: {
			maxSurge?:       uint | *1
			maxUnavailable?: uint | *0
		}
	}
}

#UpdateStrategySchema: {
	type: *"RollingUpdate" | "Recreate"

	// Only applicable when type is "RollingUpdate"
	rollingUpdate?: {
		maxSurge?:       uint | *1
		maxUnavailable?: uint | *0
	}
}
