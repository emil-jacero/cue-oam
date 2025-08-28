package core

// TODO: Add application labels automatically to the output resources

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

// Application represents a collection of components, traits, and scopes
// that together form adefinition complete application.
// It is the top-level resource in the OAM model, encapsulating all the necessary elements
// to define and deploy an application.
#Application: #Object & {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Application"

	#metadata: {
		// The name of the component, must be globally unique.
		name:       string
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels: "application.oam.dev/name": #metadata.name
		labels: "application.oam.dev/type": #metadata.type

		// A description of the component, used for documentation
		annotations: "application.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the component.
	#metadata: {
		// The type of the application.
		// Used to categorize the application.
		type: string & strings.MinRunes(1) & strings.MaxRunes(254)

		// A description of the component.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(254)
	}

	components: [...#ApplicationComponent]

	// A set of outputs that this application produces.
	// Template results from all components are merged into these outputs.
	output: {
		// Docker Compose template outputs
		compose?: v2alpha1compose.#Compose
		// compose?: {...}

		// Kubernetes resource outputs
		kubernetes?: {...} // Kubernetes resource outputs
		...
	}
}

#ApplicationComponent: #Component & {
	// The traits that are applied to this component.
	traits?: [...#Trait]

	// The scopes that this component is associated with.
	// scopes?: [...#Scope]
}
