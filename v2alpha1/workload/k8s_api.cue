package workload

import (
	core "jacero.io/oam/v2alpha1/core"
	v2alpha1schema "jacero.io/oam/v2alpha1/workload/schema"
)

// Pod is a workload type that runs a containerized application.
// It is used to define a pod specification that can be used in a deployment or statefulset.
// It will map 100% to a pod specification in Kubernetes.
#Pod: core.#Workload & {
	metadata: name: "pod.workload.oam.dev"

	metadata: {
		type:        "server"
		description: "A server workload that runs a containerized application."
		attributes: {
			replicable:  true
			daemonized:  true
			exposed:     true
			podspecable: true
		}
	}

	schema: {
		// The containers that are part of the workload
		containers: [...v2alpha1schema.#ContainerSpec]

		// initContainers are run before the main containers in the pod.
		initContainers?: [...v2alpha1schema.#ContainerSpec]

		// resources defines the compute resource requirements of the workload.
		resources: v2alpha1schema.#ResourceRequirements

		// Restart policy for the workload
		restart: v2alpha1schema.#RestartPolicy

		// Only relevant for Deployment and StatefulSet
		rollout?: {
			maxSurgePercentage?:     uint & <=100 & >=0
			minAvailablePercentage?: uint & <=100 & >=0
		}
	}
}

// Deployment is a workload type that runs a containerized application.
// It is used to define a deployment specification that can be used in a deployment.
// It will map 100% to a deployment specification in Kubernetes.
// IT will be more difficult to map to other containerized platforms, like Docker Compose.
#Deployment: core.#Workload & {
	metadata: name: "deployment.workload.oam.dev"

	metadata: {
		type:        "server"
		description: "A server workload that runs a containerized application."
		attributes: {
			replicable:  true
			daemonized:  true
			exposed:     true
			podspecable: true
		}
	}

	schema: {
		// The containers that are part of the workload
		containers: [...v2alpha1schema.#ContainerSpec]

		// initContainers are run before the main containers in the pod.
		initContainers?: [...v2alpha1schema.#ContainerSpec]

		// resources defines the compute resource requirements of the workload.
		resources: v2alpha1schema.#ResourceRequirements

		// Restart policy for the workload
		restart: v2alpha1schema.#RestartPolicy

		// Only relevant for Deployment and StatefulSet
		rollout?: {
			maxSurgePercentage?:     uint & <=100 & >=0
			minAvailablePercentage?: uint & <=100 & >=0
		}
	}
}