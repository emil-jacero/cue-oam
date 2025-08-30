package core

// TODO: Add scope labels automatically to the output resources

import (
	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

#Scope: {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Scope"

	#metadata: {
		name:       _
		namespace?: _
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "scope.oam.dev/name": #metadata.name
		labels?: "scope.oam.dev/type": #metadata.type

		annotations?: "scope.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the scope.
	#metadata: {
		type: string

		// A description of the scope.
		description?: string
	}

	properties: {...}

	// Patch the component with the scope's properties.
	patch: {
		// Docker Compose template
		compose?: v2alpha1compose.#Compose

		// Kubernetes resource template
		kubernetes?: {...}
		...
	}
}
