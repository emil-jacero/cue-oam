package compose

import (
	corev3 "jacero.io/oam/core/v3alpha1"
)

#ProviderCompose: corev3.#Provider & {
	#metadata: {
		name:        "Compose"
		description: "Provider for Docker Compose applications"
		minVersion:  "v3.8" // Minimum Docker Compose version supported
		capabilities: [
			// Supported OAM core types
			"core.oam.dev/v3alpha1.Workload",
			"core.oam.dev/v3alpha1.Database",
			"core.oam.dev/v3alpha1.Volume",
			"core.oam.dev/v3alpha1.Secret",
			"core.oam.dev/v3alpha1.Config",
			"core.oam.dev/v3alpha1.Route",
			"core.oam.dev/v3alpha1.Scaling",
		]
	}

	transformers: {
		"Workload": #WorkloadTransformer
		// "Volume":   #VolumeTransformer
		// "Secret":   #SecretTransformer
		// "Config":   #ConfigTransformer
	}
}

#WorkloadTransformer: corev3.#Transformer & {
	accepts: "Workload"
	transform: {
		input:   _
		context: corev3.#ProviderContext
		output:  corev3.#ResourceOutput
	}
}
