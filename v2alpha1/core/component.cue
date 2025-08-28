package core

// TODO: Add component labels automatically to the output resources

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

// When the component type is "workload", it must have a workload definition.
// The workload component acts as a well-known schema and template for the component's configuration and templates,
// making it easier to define and manage workloads.
// When the component type is "resource", it does not rely on a workload definition.
// The resource component type allows for more flexibility in defining the component's behavior and configuration,
// for example a resource that is not a deployable unit, like a configuration of a Kubernetes Operator.
#ComponentTypes: string & "workload" | "resource"

// A component is a reusable package of configuration and templates.
// It can include workloads, services, configs, and other resources that are needed to run the application.
// It is designed to be easily shared and reused across different applications.
#Component: #Object & {
	// The API version is locked, so that we can trust the identifier when putting components in a registry.
	#apiVersion: "core.oam.dev/v2alpha1"
	// The kind is locked, so that we can trust the identifier when putting components in a registry.
	#kind:       "Component"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "component.oam.dev/name": #metadata.name
		labels: "component.oam.dev/type": #metadata.type

		// A description of the component, used for documentation
		annotations: "component.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the component.
	#metadata: {
		type: #ComponentTypes
		if workload != _|_ {type: "workload"}
		if workload == _|_ {type: "resource"}

		// A category for the component, used to group similar components together.
		category: string & strings.MinRunes(1) & strings.MaxRunes(254)

		// A description of the component.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(254)
	}

	// If workload is defined, it is treated as a component with the type of workload.
	// Meaning it will be a runnable unit in the platform. Treat it as the primary and well-known schema and template for the component.
	// If it is omitted, the component will not have a workload definition.
	// This is usually for components which does not deploy anything runnable.
	workload?: #Workload

	context: #ObjectMeta

	// Properties are used to define the component specific configuration.
	// They are defined by the component owner, with optional defaults.
	// They are set by the user when the component is instantiated in an application
	properties: {...}

	// A set of templates that this component produces.
	// Templates are used to define the results of the component, which can be used by applications.
	template: {
		// Kubernetes resource template
		kubernetes?: {...}

		// Docker Compose template
		compose?: v2alpha1compose.#Compose
		// compose?: {...}
		...
	}

	// Status defines how the status of the component, when running, can be observed.
	status?: #Status
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
