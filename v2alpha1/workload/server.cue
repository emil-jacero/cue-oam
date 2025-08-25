package workload

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1schema "jacero.io/oam/v2alpha1/workload/schema"
)

// Server is a workload type that runs a containerized workload.
// It will expose the container ports by default.
// Generalized to run on many different containerized platforms, like Docker Compose, Kubernetes, etc.
#Server: v2alpha1core.#WorkloadType & {
	metadata: name: "server.workload.oam.dev"

	metadata: {
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
		osType?: string & "linux" | "windows"
		arch?:   string & "i386" | "amd64" | "arm" | "arm64"
		// The containers that are part of the workload
		containers: [...v2alpha1schema.#ContainerSpec]
	}
}
