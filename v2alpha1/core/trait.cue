package core

import "strings"

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
		type: string

		// A description of the trait.
		description?: string

		// What workload types this trait can be applied to.
		appliesTo: [...#Workload]
	}

	config: {...}

	templates: {
		compose: {}
		...
	}
}
