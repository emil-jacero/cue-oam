package core

// TODO: Add component labels automatically to the workload

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
)

#Component: #Object & {
	apiVersion: "component.oam.dev/v2alpha1"
	kind:       "Component"

	metadata: {
		// The name of the component, must be globally unique.
		name:       string
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "component.oam.dev/name": metadata.name
		labels?: "component.oam.dev/type": metadata.type

		// A description of the component, used for documentation
		annotations?: "definition.oam.dev/description": metadata.description
	}

	// Extended metadata and attributes for the component.
	metadata: {
		// Type of the component, which can be used to categorize the component.
		type: string

		// A description of the component.
		description?: string

		// Attributes extending the component.
		attributes: {...}
	}

	// The workload that this component represents.
	workload: #WorkloadType

	// Config are used to define the properties of the component, which can be used by the component owner to configure the outputs.
	// They are defined by the component owner, with optional defaults.
	config: {...}

	// A set of outputs that this component produces. Can be kubernetes resource templates or docker compose templates.
	// Outputs are used to define the results of the component, which can be used by applications.
	// The "main" output is the primary output of the component, and MUST be named "main".
	outputs: {
		// Docker Compose template outputs
		compose?: v2alpha1compose.#Compose

		// Kubernetes resource outputs
		kubernetes?: {...} // Kubernetes resource outputs
		...
	}
	...
}
