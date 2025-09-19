package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Config trait definition
// Defines one or more configurations
#ConfigMeta: #Config.#metadata.#traits.Config

#Config: core.#Trait & {
	#metadata: #traits: Config: core.#TraitMetaAtomic & {
		#kind:       "Config"
		description: "Describes one or more configurations to be used by containers"
		domain:      "data"
		scope: ["component"]
		provides: configMap: [string]: schema.#ConfigSpec
	}

	// Configurations to be created
	configMap: [string]: schema.#ConfigSpec
}
