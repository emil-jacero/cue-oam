package examples

// Component definition - collection of traits
#Component: {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Component"
	#metadata: #ComponentMeta & {
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	#Trait
}

// Component metadata with trait tracking
#ComponentMeta: {
	#id:  #NameType
	name: #NameType | *#id

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
	...
}

#ScopeMeta: {
	#id:  #NameType
	name: #NameType | *#id

	// Attributes extending the scope.
	attributes: [string]: bool
	attributes: {
		// Whether the scope provides network isolation for its components.
		networkIsolated?: bool

		// Whether the scope enforces resource quotas on its components.
		resourceQuotas?: bool
	}
	...
}

#Scope: {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Scope"
	#metadata: #ScopeMeta & {
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	#Trait
}
