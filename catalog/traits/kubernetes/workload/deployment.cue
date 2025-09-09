package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// DeploymentTrait defines the properties and behaviors of a Kubernetes Deployment
#DeploymentTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Deployment"

	description: "Kubernetes Deployment for stateless workloads with rolling updates"

	type:   "atomic"
	domain: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/apps/v1.Deployment",
	]

	provides: {
		deployment: schema.Deployment
	}
}
#Deployment: core.#Trait & {
	#metadata: #traits: Deployment: #DeploymentTrait
	deployment: schema.Deployment
}

// DeploymentsTrait defines the properties and behaviors of multiple Kubernetes Deployments
#DeploymentsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Deployments"

	description: "Kubernetes Deployments for stateless workloads with rolling updates"

	type:   "atomic"
	domain: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/apps/v1.Deployment",
	]

	provides: {
		deployments: [string]: schema.Deployment
	}
}
#Deployments: core.#Trait & {
	#metadata: #traits: Deployments: #DeploymentsTrait
	deployments: [string]: schema.Deployment
}
