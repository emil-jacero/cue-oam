package core

import (
	"list"

	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
	v2alpha2compose "jacero.io/oam/v2alpha2/schema/compose"
)

#Trait: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Trait"

	#metadata: {
		name:       _
		namespace?: _
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "trait.oam.dev/name": #metadata.name

		annotations?: "trait.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the trait.
	#metadata: {
		// A description of the trait.
		description?: string

		// Attributes extending the trait.
		attributes: [string]: bool

		// What schema types this trait can be applied to.
		appliesTo!: list.UniqueItems() & [...#SchemaTypes]

		conflictsWith: [...#Trait]
	}

	// Inject component so that it can be referenced in the template.
	#component: #Component

	properties: {...}

	template: {
		kubernetes: resources: [...v2alpha2k8s.#Object]
		compose: v2alpha2compose.#Compose
	}
}
