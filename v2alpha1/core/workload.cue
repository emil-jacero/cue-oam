package core

#WorkloadTypes: string & "server" | "worker" | "task" | "database"

#Workload: #Object & {
	#apiVersion: "core.oam.dev/v2alpha1"
	#kind:       "Workload"

	#metadata: {
		// The name of the workload, must be globally unique.
		name:       string
		namespace?: string
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "workload.oam.dev/name": #metadata.name
		labels?: "workload.oam.dev/type": #metadata.type

		annotations?: "workload.oam.dev/description": #metadata.description
		for k, v in #metadata.attributes {
			annotations?: "workload.oam.dev/\(k)": v
		}
	}

	// Extended metadata and attributes for the workload.
	#metadata: {
		// The type of workload, e.g. "server", "worker", "task"
		type: #WorkloadTypes

		// A description of the workload type
		description?: string

		// Attributes extending the workload type.
		attributes: {
			// Whether they are replicable. If not, no replication or scaling traits may be assigned.
			replicable?: bool

			// Whether they are daemonized. For daemon types, if the workload exits, this is considered a fault, and the system must fix it.
			// For non-daemonized types, exit is considered a success if no error is reported.
			daemonized?: bool

			// Whether they are exposed, i.e. have a service endpoint with a stable name for network traffic.
			// Workload types that have a service endpoint need a virtual IP address (VIP) with a DNS name to represent the component as a whole,
			// addressable within their network scope and can be assigned traffic routing traits.
			exposed?: bool

			// Whether this workload can be addressed by Kubernetes PodSpec.
			// If yes, the implementation could manipulate the workload by leveraging PodSpec structure,
			// instead of being agnostic of the workload's schematic.
			podspecable?: bool
			...
		}
	}

	schema: {...}
}
