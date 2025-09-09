package standard

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/schema"
)

// Volume trait definition
// Describes a set of volumes
#VolumeTraitMeta: core.#TraitMetaAtomic & {
	#kind:       "Volume"
	description: "Describes a set of volumes to be used by containers"
	domain:      "resource"
	scope: ["component"]
	requiredCapability: "core.oam.dev/v2alpha1.Volume"
	provides: {
		volumes: [string]: schema.#VolumeSpec
	}
}
#Volume: core.#Trait & {
	#metadata: #traits: Volume: #VolumeTraitMeta

	// Volumes to be created
	volumes: #VolumeTraitMeta.provides.volumes
	// Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
	for k, v in volumes {
		volumes: (k): v & {
			name: string | *k
		}
	}
}

// Secret trait definition
// Describes a set of secrets
#SecretTraitMeta: core.#TraitMetaAtomic & {
	#kind:       "Secret"
	description: "Describes a set of secrets to be used by containers"
	domain:      "resource"
	scope: ["component"]
	requiredCapability: "core.oam.dev/v2alpha1.Secret"
	provides: {
		secrets: [string]: schema.#SecretSpec
	}
}
#Secret: core.#Trait & {
	#metadata: #traits: Secret: #SecretTraitMeta

	// Secrets to be created
	secrets: #SecretTraitMeta.provides.secrets
}

// Config trait definition
// Defines one or more configurations
#ConfigTraitMeta: core.#TraitMetaAtomic & {
	#kind:       "Config"
	description: "Describes one or more configurations to be used by containers"
	domain:      "resource"
	scope: ["component"]
	requiredCapability: "core.oam.dev/v2alpha1.Config"
	provides: {
		configMap: [string]: schema.#ConfigSpec
	}
}
#Config: core.#Trait & {
	#metadata: #traits: Config: #ConfigTraitMeta

	// Configurations to be created
	configMap: #ConfigTraitMeta.provides.configMap
}
