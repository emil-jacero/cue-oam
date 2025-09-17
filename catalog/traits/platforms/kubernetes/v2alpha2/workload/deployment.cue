package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Deployment defines the properties and behaviors of a Kubernetes Deployment
#Deployment: core.#Trait & {
	#metadata: #traits: Deployment: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/apps/v1"
		#kind:       "Deployment"
		description: "Kubernetes Deployment for stateless workloads with rolling updates"
		domain:      "workload"
		scope: ["component"]
		provides: {deployment: schema.#DeploymentSpec}
	}
	deployment: schema.#DeploymentSpec
}

#DeploymentMeta: #Deployment.#metadata.#traits.Deployment
