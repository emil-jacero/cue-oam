package compose

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ProviderCompose: core.#Provider & {
	#metadata: {
		name:        "Compose"
		description: "Provider for Docker Compose applications"
		minVersion:  "v3.8" // Minimum Docker Compose version supported
	}

	// Transformers define which traits this provider supports.
	// Supported traits have transformer definitions, unsupported traits can be:
	// - Set to null (explicit unsupported)
	// - Omitted entirely (implicit unsupported)
	transformers: {
		// Supported traits
		"core.oam.dev/v2alpha2.ContainerSet": #ContainerSetTransformer

		// Unsupported traits - explicitly marked as null
		// These could also be omitted entirely
		"core.oam.dev/v2alpha2.Expose": null
		"core.oam.dev/v2alpha2.Volume": null
		"core.oam.dev/v2alpha2.Secret": null
		"core.oam.dev/v2alpha2.Config": null
	}
}

#ContainerSetTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2/ContainerSet"
	transform: {
		input:   _
		context: core.#ProviderContext
		output:  core.#ResourceOutput
	}
}
