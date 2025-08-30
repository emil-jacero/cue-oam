package core

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

// A component is a reusable package of configuration and templates.
// It can include workloads, services, configs, and other resources that are needed to run the application.
// It is designed to be easily shared and reused across different applications.
#Component: #Object & {
	#apiVersion: "core.oam.dev/v3alpha1"
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
		// A category for the component, used to group similar components together.
		category: string & strings.MinRunes(1) & strings.MaxRunes(254)

		// A description of the component.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(254)

		// Attributes extending the workload type.
		attributes: {
			// Whether the component supports replication and scaling.
			replicable?: bool

			// Whether the workload must run continuously. 
			// Daemonized workloads treat exit as a fault; non-daemonized workloads 
			// treat exit as success if no error is reported.
			daemonized?: bool

			// Whether the component exposes a stable service endpoint.
			// Exposed workloads require a VIP and DNS name within their network scope.
			exposed?: bool

			// Whether the workload can be represented as a Kubernetes PodSpec.
			// If true, implementations may manipulate the workload via PodSpec structures.
			podspecable?: bool
			...
		}
	}

	schema!: #Schema

	// A predefined schema for the component's context. Is injected into the component at runtime.
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
