package core

// TODO: Add application labels automatically to the components

import (
	"strings"

	// v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
)

// Application represents a collection of components, traits, and scopes
// that together form a complete application.
// It is the top-level resource in the OAM model, encapsulating all the necessary elements
// to define and deploy an application.
#Application: #Object & {
	apiVersion: "application.oam.dev/v2alpha1"
	kind:       "Application"

	metadata: {
		// The name of the component, must be globally unique.
		name:       string & strings.MaxRunes(254)
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "application.oam.dev/name": metadata.name
		labels?: "application.oam.dev/type": metadata.type

		// A description of the component, used for documentation
		annotations?: "definition.oam.dev/description": metadata.description
	}

	// Extended metadata and attributes for the component.
	metadata: {
		// The parameter's type. One of boolean, number, string, or null
		// as defined in the JSON specification and the JSON Schema
		// Validation spec
		type: string

		// A description of the component.
		description?: string

		// Attributes extending the component.
		attributes: {...}
	}

	components: [...#ApplicationComponent]

	// A set of outputs that this application produces. Can be kubernetes resource templates or docker compose templates.
	// Outputs from all components are merged into these outputs.
	outputs: {
		// Docker Compose template outputs
		// compose?: v2alpha1compose.#Compose
		compose?: {...}
		// if compose != _|_ {
		// 	for component in components {
		// 		if component.outputs.compose != _|_ {
		// 			for value in component.outputs.compose {
		// 				compose: value
		// 			}
		// 		}
		// 	}
		// }

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
