package workload

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1schema "jacero.io/oam/v2alpha1/schema"
)

// ContainerizedWorkload is a generic containerized workload. It will deploy one or more containers.
// It borrows heavily from Kubernetes but is meant to make it easier to also run on other containerized platforms.
// TODO: Add support for initContainers
#ContainerizedWorkload: v2alpha1core.#Workload & {
	#metadata: name: "containerized.workload.core.oam.dev"

	#metadata: {
		apiVersion:  "core.oam.dev/v2alpha1"
		kind:        "ContainerizedWorkload"
		type:        "server"
		description: "A server workload that runs a containerized application."
		attributes: {
			replicable:  true
			daemonized:  true
			exposed:     true
			podspecable: false
		}
	}

	schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"
		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"
		// The containers that are part of the workload.
		// The first container is treated as the MAIN container. This is important when transforming 
		containers: [...v2alpha1schema.#ContainerSpec]
		// initContainers are run before the main containers.
		// They can be used to set up the environment for the main containers.
		initContainers: [...v2alpha1schema.#ContainerSpec]
	}
}
