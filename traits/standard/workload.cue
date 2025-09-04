package standard

import (
	"strings"
	corev3 "jacero.io/oam/core/v3alpha1"
)

// Webservice is a service-oriented components are components that support external access to services with the container as the core, and their functions cover the needs of most of he microservice scenarios.
#WebService: corev3.#Trait & {
	#metadata: #traits: WebService: {
		provides: {webservice: #WebService.webservice}
		requires: [
			"core.oam.dev/v3alpha1.Workload",
		]
		extends: [#Workload.#metadata.#traits.Workload, #Exposable.#metadata.#traits.Exposable]
		description: "Describes a long-running, scalable, containerized service that runs with a network endpoint to receive external network traffic."
	}

	webservice: {
		deploymentType: *"Deployment" | "StatefulSet"
		expose?:        #Exposable.expose
		workload: #Workload.workload & {
			replicas?: uint | *1
		}
	}
}

// Worker describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic. 
#Worker: corev3.#Trait & {
	#metadata: #traits: Worker: {
		provides: {worker: #Worker.worker}
		requires: [
			"core.oam.dev/v3alpha1.Workload",
		]
		extends: [#Workload.#metadata.#traits.Workload]
		description: "Describes a long-running, scalable, containerized service that runs in the background without a network endpoint."
	}

	worker: {
		replicas?: uint | *1
		workload: #Workload.workload & {
			deploymentType: *"Deployment" | "StatefulSet"
		}
	}
}

// Workload trait definition
// Defaults to a single container workload for simplicity
// In Kubernetes this maps to a Deployment with a single container. Sidecars can be added via other traits.
#Workload: corev3.#Trait & {
	#metadata: #traits: Workload: {
		provides: {workload: #Workload.workload}
		requires: [
			"core.oam.dev/v3alpha1.Workload",
		]
		description: "Describes a workload that runs one or more containers. By default, the workload runs a single container called 'main'."
	}

	workload: {
		containers: [string]: #ContainerSpec
		containers: main: {name: string | *#metadata.name}

		// Optional init containers that run before the main containers
		initContainers?: [string]: #ContainerSpec

		// Restart policy for all containers
		// Can be overridden per container
		// Defaults to "Always"
		restart: *"Always" | "OnFailure" | "Never"

		// Deployment type for the workload
		// In Kubernetes this maps to Deployment, StatefulSet or DaemonSet
		// For Docker Compose Deployment is mapped to service, DaemonSet and StatefulSet are not supported
		deploymentType?: *"Deployment" | "StatefulSet" | "DaemonSet"
		if deploymentType != _|_ {
			if deploymentType == "Deployment" {
				replicas?: uint | *1
				strategy?: *"Recreate" | "RollingUpdate"
				rollingUpdate?: {
					maxSurge?:       uint | *1
					maxUnavailable?: uint | *0
				}
			}
			if deploymentType == "StatefulSet" {
				replicas?:            uint | *1
				serviceName!:         string & strings.MaxRunes(253)
				podManagementPolicy?: *"OrderedReady" | "Parallel"
				updateStrategy?:      *"OnDelete" | "RollingUpdate"
				rollingUpdate?: {
					partition?: uint | *0
				}
			}
			if deploymentType == "DaemonSet" {
				updateStrategy?: *"OnDelete" | "RollingUpdate"
				rollingUpdate?: {
					maxUnavailable?: uint | *1
				}
			}
		}
	}
}

// Extends a workload to add support for scaling the number of replicas
#Replicable: corev3.#Trait & {
	#metadata: #traits: Replicable: {
		provides: {replicas: #Replicable.replicas}
		requires: [
			"core.oam.dev/v3alpha1.Replicable",
		]
		extends: [#Workload.#metadata.Workload]
		description: "Extends Workload to add support for scaling the number of replicas."
	}

	// Number of replicas for the workload
	replicas: {
		min: uint | *1
		max: uint & >=min | *min
	}
}

// Defines a workload that can be exposed on a stable network endpoint
// In Kubernetes this maps to a Service
#Exposable: corev3.#Trait & {
	#metadata: #traits: Exposable: {
		provides: {expose: #Exposable.expose}
		requires: [
			"core.oam.dev/v3alpha1.Exposable",
		]
		description: "Extends Workload to add support for exposing the workload on a stable network endpoint."
	}

	// A named list of ports to expose from the workload
	// The port field can either inherit from a container port or specify a new port
	// In Kubernetes this maps to a Service with type ClusterIP, NodePort or LoadBalancer
	expose: [string]: {
		// If exposedPort is not specified, containerPort will be used for exposing the port outside the container.
		port: #Port
		loadBalancer?: {
			idleTimeoutSeconds?: uint & >=1 & <=4000 | *60
			stickySessions?: {
				cookieName?: string & strings.MaxRunes(200)
				cookieTTL?:  string | *"0s"
			}
		}
		nodePort?: uint16 & >=30000 & <=32767
	}
}

// Defines a workload that runs code or a script to completion.
// Combined with #Workload to define a job that runs to completion
#Task: corev3.#Trait & {
	#metadata: #traits: Task: {
		provides: {task: #Task.task}
		requires: [
			"core.oam.dev/v3alpha1.Task",
		]
		extends: [#Workload.#metadata.Workload]
		description: "Describes jobs that run code or a script to completion. Tasks can be run once or on a regular schedule."
	}

	// Creates a one-off task
	// In Kubernetes this maps to a Job
	task: {
		completions?:           uint
		parallelism?:           uint
		activeDeadlineSeconds?: uint
		backoffLimit?:          uint | *6
	}

	// Scheduled tasks
	// In Kubernetes this maps to a CronJob
	schedule?: {
		// Example of job definition:
		// .---------------- minute (0 - 59)
		// |  .------------- hour (0 - 23)
		// |  |  .---------- day of month (1 - 31)
		// |  |  |  .------- month (1 - 12)
		// |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
		// |  |  |  |  |
		// *  *  *  *  *
		schedule: =~"((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})"

		concurrency: {
			enable:  bool | *true
			replace: bool | *false
		}

		startingDeadlineSeconds?: uint
		historyLimit?: {
			successful?: uint
			failed?:     uint
		}
	}
	workload: #Workload.workload & {
		restart: *"OnFailure" | "Never"
	}
}

// Register the trait
#Registry: corev3.#TraitRegistry & {
	traits: {
		"WebService": #WebService
		"Worker":     #Worker
		"Workload":   #Workload
		"Replicable": #Replicable
		"Exposable":  #Exposable
		"Task":       #Task
	}
}
