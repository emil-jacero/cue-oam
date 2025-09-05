package standard

import (
	corev2 "jacero.io/oam/core/v2alpha1"
)

// Defines one or more configurations
#Config: corev2.#Trait & {
	#metadata: #traits: Config: {
		provides: {configMap: #Config.configMap}
		requires: [
			"core.oam.dev/v2alpha1.Config",
		]
		description: "Describes a set of configurations"
	}

	// Configurations to be created
	configMap: [string]: #ConfigSpec
}

// Register the trait
#Registry: corev2.#TraitRegistry & {
	traits: {
		"Config": #Config
	}
}
