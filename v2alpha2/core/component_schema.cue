package core

import (
	"strings"
)

#SchemaTypes:           string & #WildcardWorkloadTypes | #GenericWorkloadTypes | #K8sWorkloadTypes
#WildcardWorkloadTypes: string & "*"
#GenericWorkloadTypes:  string & #TypeWebservice | #TypeWorker | #TypeTask | #TypeScheduledTask | #TypeDatabase
#K8sWorkloadTypes:      string & "deployments.apps" | "statefulsets.apps" | "daemonsets.apps" | "jobs.batch" | "cronjobs.batch" | "configmaps.core" | "secrets.core"

// Describes service-oriented components that support external access to services with the container as the core.
#TypeWebservice: string & "webservice"

// Describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic.
#TypeWorker: string & "worker"

// Describes short-lived, one-off, containerized tasks that run to completion. They do NOT have network endpoint to receive external network traffic.
#TypeTask: string & "task"

// Describes scheduled, one-off, containerized tasks that run at specified intervals. They do NOT have network endpoint to receive external network traffic.
#TypeScheduledTask: string & "scheduled-task"

// Describes stateful, scalable, containerized services that manage data.
#TypeDatabase: string & "database"

#ComponentSchema: #Object & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ComponentSchema"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "component-schema.oam.dev/name": #metadata.name
		labels: "component-schema.oam.dev/type": #metadata.type

		annotations: "component-schema.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the component.
	#metadata: {
		type!:        #SchemaTypes
		description?: string & strings.MinRunes(1) & strings.MaxRunes(1024)

		// Attributes extending the component type.
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

	#schema: {...}
}
