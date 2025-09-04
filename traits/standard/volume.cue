package standard

import (
	corev3 "jacero.io/oam/core/v3alpha1"
)

// Defines one or more volumes
#Volume: corev3.#Trait & {
	#metadata: #traits: Volume: {
		provides: {volumes: #Volume.volumes}
		requires: [
			"core.oam.dev/v3alpha1.Volume",
		]
	}

	// Volumes to be created
	volumes: [string]: #VolumeSpec
}

// Register the trait
#Registry: corev3.#TraitRegistry & {
	traits: {
		"Volume": #Volume
	}
}
