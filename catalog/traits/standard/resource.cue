package standard

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/schema"
)

// Volume trait definition
// Describes a set of volumes
#Volume: core.#Trait & {
	#metadata: #traits: Volume: #VolumeTrait

	// Volumes to be created
	volumes: [string]: schema.#VolumeSpec
	// Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
	for k, v in volumes {
		volumes: (k): v & {
			name: string | *k
		}
	}
}
#VolumeTrait: core.#TraitObject & {
	#kind:    "Volume"
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Volume",
	]
	provides: {volumes: #Volume.volumes}
}

// Secret trait definition
// Describes a set of secrets
#Secret: core.#Trait & {
	#metadata: #traits: Secret: #SecretTrait

	// Secrets to be created
	secrets: [string]: schema.#SecretSpec
}
#SecretTrait: core.#TraitObject & {
	#kind:    "Secret"
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Secret",
	]
	provides: {secrets: #Secret.secrets}
}

// Config trait definition
// Defines one or more configurations
#Config: core.#Trait & {
	#metadata: #traits: Config: #ConfigTrait

	// Configurations to be created
	configMap: [string]: schema.#ConfigSpec
}
#ConfigTrait: core.#TraitObject & {
	#kind:    "Config"
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Config",
	]
	provides: {configMap: #Config.configMap}
}
