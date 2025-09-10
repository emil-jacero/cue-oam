package v2alpha2

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/v2alpha2/schema"
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

// Secret trait definition
// Describes a set of secrets
#SecretTraitMeta: #Secret.#metadata.#traits.Secret

#Secret: core.#Trait & {
	#metadata: #traits: Secret: core.#TraitMetaAtomic & {
		#kind:       "Secret"
		description: "Describes a set of secrets to be used by containers"
		domain:      "resource"
		scope: ["component"]
		provides: {secrets: #Secret.secrets}
	}

	// Secrets to be created
	secrets: [string]: schema.#SecretSpec
}

// Config trait definition
// Defines one or more configurations
#ConfigTraitMeta: #Config.#metadata.#traits.Config

#Config: core.#Trait & {
	#metadata: #traits: Config: core.#TraitMetaAtomic & {
		#kind:       "Config"
		description: "Describes one or more configurations to be used by containers"
		domain:      "resource"
		scope: ["component"]
		provides: {configMap: #Config.configMap}
	}

	// Configurations to be created
	configMap: [string]: schema.#ConfigSpec
}
