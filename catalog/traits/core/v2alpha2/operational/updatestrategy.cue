package operational

import (
	core "jacero.io/oam/core/v2alpha2"
)

// UpdateStrategy - Controls how updates are applied
#UpdateStrategyTraitMeta: #UpdateStrategy.#metadata.#traits.UpdateStrategy

#UpdateStrategy: core.#Trait & {
	#metadata: #traits: UpdateStrategy: core.#TraitMetaAtomic & {
		#kind:       "UpdateStrategy"
		description: "Defines how updates are applied to running instances"
		domain:      "operational"
		scope: ["component"]
		// This trait modifies Deployment/StatefulSet created by ContainerSet
		dependencies: [#ContainerSetTraitMeta]
		provides: {updateStrategy: #UpdateStrategy.updateStrategy}
	}

	updateStrategy: {
		type: *"RollingUpdate" | "Recreate"

		// Only applicable when type is "RollingUpdate"
		if type == "RollingUpdate" {
			rollingUpdate?: {
				maxSurge?:       uint | *1
				maxUnavailable?: uint | *0
			}
		}
	}
}