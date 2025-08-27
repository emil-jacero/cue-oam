package core

// TODO: Add trait labels automatically to the output resources

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

#TraitTypes: string & "scaling" | "networking" | "storage" | "security" | "monitoring"

#Trait: {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Trait"

	#metadata: {
		name:       string & strings.MaxRunes(254)
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "trait.oam.dev/name": #metadata.name
		labels?: "trait.oam.dev/type": #metadata.type

		annotations?: "trait.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the trait.
	#metadata: {
		type: #TraitTypes

		// A description of the trait.
		description?: string

		// What workload types this trait can be applied to.
		appliesTo: [...#Workload]
	}

	config: {...}

	// Patch the component with the trait's configuration.
	patch: {
		// Docker Compose template
		compose?: v2alpha1compose.#Compose

		// Kubernetes resource template
		kubernetes?: {...}
		...
	}
}
