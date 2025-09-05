package standard

import (
	corev2 "jacero.io/oam/core/v2alpha1"
)

// Defines one or more volumes
#Volume: corev2.#Trait & {
	#metadata: #traits: Volume: {
		provides: {volumes: #Volume.volumes}
		requires: [
			"core.oam.dev/v2alpha1.Volume",
		]
	}

	// Volumes to be created
	volumes: [string]: #VolumeSpec
	// Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
	for k, v in volumes {
		volumes: (k): v & {
			name: string | *k
		}
	}
}

// Register the trait
#Registry: corev2.#TraitRegistry & {
	traits: {
		"Volume": #Volume
	}
}
