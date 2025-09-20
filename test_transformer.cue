package test

import (
	k8s "jacero.io/oam/providers/kubernetes"
	core "jacero.io/oam/core/v2alpha2"
	traits "jacero.io/oam/catalog/traits/core/v2alpha2"
	workload "jacero.io/oam/catalog/traits/core/v2alpha2/workload"
)

// Test transformer with required and optional traits
testTransformer: k8s.#Transformer & {
	creates: "k8s.io/api/apps/v1.Deployment"

	required: [
		"core.oam.dev/v2alpha2.ContainerSet",
		"core.oam.dev/v2alpha2.DeploymentType",
	]

	optional: [
		"core.oam.dev/v2alpha2.UpdateStrategy",
		"core.oam.dev/v2alpha2.RestartPolicy",
		"core.oam.dev/v2alpha2.Replicas",
	]

	validates: {
		deploymentType: "Deployment"
	}

	// Defaults should be auto-generated from optional trait schemas
	// Let's check if they are populated

	transform: {
		component: core.#Component
		context:   core.#ProviderContext
		output: []
	}
}

// Test component with required traits
validComponent: core.#Component & {
	#metadata: {
		name: "test-app"
		#traits: {
			ContainerSet:   traits.#ContainerSetMeta
			DeploymentType: workload.#DeploymentTypeMeta
		}
	}

	containerSet: containers: main: {
		name: "app"
		image: {
			repository: "nginx"
			tag:        "latest"
		}
	}

	deploymentType: {
		type: "Deployment"
	}
}

// Test validation
validation: k8s.#ValidateTransformer & {
	component:   validComponent
	transformer: testTransformer
}

// Check if defaults are populated
defaultsCheck: testTransformer.defaults
