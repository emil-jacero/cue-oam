package standard

import (
	corev3 "jacero.io/oam/core/v3alpha1"
)

// Defines one or more configurations
#Config: corev3.#Trait & {
	#metadata: #traits: Config: {
		provides: {configs: #Config.configs}
		requires: [
			"core.oam.dev/v3alpha1.Config",
		]
		description: "Describes a set of configurations"
	}

	// Configurations to be created
	configs: [string]: #ConfigSpec
}

// Register the trait
#Registry: corev3.#TraitRegistry & {
	traits: {
		"Config": #Config
	}
}
