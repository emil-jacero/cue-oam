package core

// TODO: Add component labels automatically to the output resources

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

// When the component type is "workload", it must have a workload definition.
// The workload component acts as a well-known schema and template for the component's configuration and templates,
// making it easier to define and manage workloads.
// When the component type is "generic", it does not rely on a workload definition.
// The generic component type allows for more flexibility in defining the component's behavior and configuration,
// for example a resource that is not a deployable unit, like a configuration of a Kubernetes Operator.
#ComponentTypes: string | *"workload" | "generic"

#Component: #Object & {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Component"

	#metadata: {
		// The name of the component, must be globally unique.
		name:       string
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "component.oam.dev/name": #metadata.name
		labels?: "component.oam.dev/type": #metadata.type

		// A description of the component, used for documentation
		annotations?: "component.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the component.
	#metadata: {
		// Type of the component, which can be used to categorize the component.
		type: #ComponentTypes

		// A category for the component, used to group similar components together.
		category: string & strings.MinRunes(1) & strings.MaxRunes(254)

		// A description of the component.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(254)
	}

	// The workload type that this component represents.
	// Acts as the primary and well-known schema and template for the component.
	if #metadata.type == "workload" {
		workload!: #Workload
	}

	// Config are used to define the properties of the component.
	// They are defined by the component owner, with optional defaults.
	// Treat them as standardized inputs to the component.
	config: {...}

	// A set of templates that this component produces.
	// Templates are used to define the results of the component, which can be used by applications.
	template: {
		// Docker Compose template
		compose?: v2alpha1compose.#Compose
		// compose?: {...}

		// Kubernetes resource template
		kubernetes?: {...}
		...
	}

	// Status defines how the status of the component, when running, can be observed.
	status: #Status
	...
}

#Status: {
	// CustomStatus defines the custom status message that could display to user.
	customStatus: {...}
	// HealthPolicy defines the health check policy for the abstraction.
	healthPolicy: {...}
	// Details stores a string representation of a CUE status map to be evaluated at runtime for display.
	details: {...}
}