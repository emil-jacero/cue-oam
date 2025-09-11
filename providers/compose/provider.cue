package compose

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ProviderCompose: core.#Provider & {
	#metadata: {
		name:        "Compose"
		description: "Provider for Docker Compose applications"
		minVersion:  "v3.8" // Minimum Docker Compose version supported
		capabilities: [
			// Supported OAM core types
			"core.oam.dev/v2alpha1.Workload",
			"core.oam.dev/v2alpha1.Database",
			"core.oam.dev/v2alpha1.Volume",
			"core.oam.dev/v2alpha1.Secret",
			"core.oam.dev/v2alpha1.Config",
			"core.oam.dev/v2alpha1.Route",
			"core.oam.dev/v2alpha1.Scaling",
		]
	}

	transformers: {
		"Workload": #WorkloadTransformer
		// "Volume":   #VolumeTransformer
		// "Secret":   #SecretTransformer
		// "Config":   #ConfigTransformer
	}
}

#WorkloadTransformer: core.#Transformer & {
	accepts: "Workload"
	transform: {
		input:   _
		context: core.#ProviderContext
		output:  core.#ResourceOutput
	}
}
