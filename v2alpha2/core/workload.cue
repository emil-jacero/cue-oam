package core

import (
	"strings"
)

#WorkloadTypes:        string & #AllWorkloadTypes | #GenericWorkloadTypes | #K8sWorkloadTypes
#AllWorkloadTypes:     string & "*"
#GenericWorkloadTypes: string & #TypeWebservice | #TypeWorker | #TypeTask | #TypeScheduledTask | #TypeDatabase
#K8sWorkloadTypes:     string & "deployments.apps" | "statefulsets.apps" | "daemonsets.apps" | "jobs.batch" | "cronjobs.batch" | "configmaps.core" | "secrets.core"

#TypeWebservice: string & "webservice" // Describes service-oriented components that support external access to services with the container as the core.

#TypeWorker: string & "worker" // Describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic.

#TypeTask: string & "task" // Describes short-lived, one-off, containerized tasks that run to completion. They do NOT have network endpoint to receive external network traffic.

#TypeScheduledTask: string & "scheduled-task" // Describes scheduled, one-off, containerized tasks that run at specified intervals. They do NOT have network endpoint to receive external network traffic.

#TypeDatabase: string & "database" // Describes stateful, scalable, containerized services that manage data.

#Workload: #Object & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Workload"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "workload.oam.dev/name": #metadata.name
		labels: "workload.oam.dev/type": #metadata.type

		annotations: "workload.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the workload.
	#metadata: {
		type:         #WorkloadTypes
		description?: string & strings.MinRunes(1) & strings.MaxRunes(1024)

		// Attributes extending the workload type.
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

	schema: {...}
}
