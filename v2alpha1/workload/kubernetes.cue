package workload

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1schemak8s "jacero.io/oam/v2alpha1/schema/kubernetes"
)

// Deployment 
#Deployment: v2alpha1core.#Workload & {
	#metadata: name: "deployment.workload.core.oam.dev"

	#metadata: {
		apiVersion:  "apps/v1"
		kind:        "Deployment"
		type:        "server"
		description: "A server workload that runs a containerized application."
		attributes: {
			replicable:  true
			daemonized:  true
			exposed:     true
			podspecable: true
		}
	}

	schema: v2alpha1schemak8s.#Deployment
}
