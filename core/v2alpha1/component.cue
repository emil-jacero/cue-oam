package v2alpha1

// Component definition - collection of traits
#Component: #Object & {
	#kind: "Component"
	#metadata: #ComponentMeta & {
		labels?:      #LabelsType
		annotations?: #AnnotationsType

		// Attributes extending the component.
		attributes: [string]: bool
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
		}
	}
	#Trait
}

// Base trait that all traits extend
#Trait: {
	#metadata: #ComponentMeta
	...
}

#TraitsMeta: {
	// Which fields this trait adds to a component.
	// Must be a list of CUE paths, e.g. {workload: #Workload.workload}
	provides!: {...}

	// Platform capabilities required by this trait to function.
	// Used to ensure that the target platform supports the trait.
	requires!: [...string]

	// Optionally, which trait this trait extends
	extends?: [...#TraitsMeta]

	// Optional short description of the trait
	description?: string
}

// Component metadata with trait tracking
#ComponentMeta: #CommonObjectMeta & {
	// Track which traits this component has
	#traits!: [string]: #TraitsMeta
}
