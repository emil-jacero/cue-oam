package core

import (
	"strings"

	v2alpha2compose "jacero.io/oam/v2alpha2/schema/compose"
	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
)

// A component is a reusable package of configuration and templates.
// It can include workloads, services, configs, and other resources that are needed to run the application.
// It is designed to be easily shared and reused across different applications.
#Component: #Object & {
	#apiVersion: "core.oam.dev/v2alpha2"
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
		// Inherits type from the workload.
		type: #ComponentTypes
		type: #workload.#metadata.type

		// A description of the component.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(254)
	}

	// Primary schema to represent the component's workload.
	#workload!: #ComponentType

	// A predefined schema for the component's context. Is injected into the component at runtime.
	#context: #ContextMeta

	// Properties are used to define the component specific configuration.
	// They are defined by the component owner, with optional defaults.
	// They are set by the user when the component is instantiated in an application
	properties: {...}

	// A set of templates that this component produces.
	// Templates are used to define the results of the component, which can be used by applications.
	template: {
		// Kubernetes resource template
		kubernetes: resources: [...v2alpha2k8s.#Object]

		// Docker Compose template
		compose: v2alpha2compose.#Compose
		...
	}

	// Status defines how the status of the component, when running, can be observed.
	status?: #Status
}

#Status: {
	// CustomStatus defines the custom status message that could display to user.
	customStatus: {...}
	// HealthPolicy defines the health check policy for the abstraction.
	healthPolicy: {...}
	// Details stores a string representation of a CUE status map to be evaluated at runtime for display.
	details: {...}
}
