package kubernetes

import (
)
// v2alpha2core "jacero.io/oam/v2alpha2/core"
// "strings"

// v2alpha2core.#Schema & 
#Webservice: {
	#metadata: {
		name:        "webservice.schema.core.oam.dev"
		type:        "webservice"
		description: "A schema for a web service workload"
	}
	schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"
		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"

		// The containers that are part of the workload.
		// The first container is treated as the MAIN container. This is important when transforming 
		containers: [...#ContainerSpec]

		// initContainers are run before the main containers.
		// They can be used to set up the environment for the main containers.
		initContainers?: [...#ContainerSpec]
	}
}
