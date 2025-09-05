package compose

import (
	corev2 "jacero.io/oam/core/v2alpha1"
)

#ProviderCompose: corev2.#Provider & {
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

#WorkloadTransformer: corev2.#Transformer & {
	accepts: "Workload"
	transform: {
		input:   _
		context: corev2.#ProviderContext
		output:  corev2.#ResourceOutput
	}
}
