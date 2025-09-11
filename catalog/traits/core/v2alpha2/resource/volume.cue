package resource

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Volume trait definition
// Describes a set of volumes
#VolumeTraitMeta: #Volume.#metadata.#traits.Volume

#Volume: core.#Trait & {
	#metadata: #traits: Volume: core.#TraitMetaAtomic & {
		#kind:       "Volume"
		description: "Describes a set of volumes to be used by containers"
		domain:      "resource"
		scope: ["component"]
		provides: {volumes: #Volume.volumes}
	}

	// Volumes to be created
	volumes: [string]: schema.#VolumeSpec
	// Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
	for k, v in volumes {
		volumes: (k): v & {
			name: string | *k
		}
	}
}