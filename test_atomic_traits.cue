package test

import (
	core "jacero.io/oam/core/v2alpha2"
	workload "jacero.io/oam/catalog/traits/core/v2alpha2/workload"
)

// Test component with DeploymentType trait
testComponent: core.#Component & {
	#metadata: {
		name: "test-component"
		#traits: {
			DeploymentType: workload.#DeploymentTypeMeta
		}
	}

	// This should be provided by the trait
	deploymentType: {
		type: "Deployment"
	}
}

// Verify #atomicTraits extracts the trait correctly
atomicTraits: testComponent.#metadata.#atomicTraits

// Expected output: ["core.oam.dev/v2alpha2.DeploymentType"]