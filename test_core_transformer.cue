package test

import (
	core "jacero.io/oam/core/v2alpha2"
	traits "jacero.io/oam/catalog/traits/core/v2alpha2"
)

// Simple test transformer using core interface
testTransformer: core.#Transformer & {
	creates: "test.Resource"
	
	required: [
		"core.oam.dev/v2alpha2.ContainerSet",
	]
	
	registry: traits.#TraitRegistry
	
	transform: {
		component: core.#Component
		context:   core.#ProviderContext
		output:    []
	}
}

// Test that the transformer structure is valid
transformerCheck: testTransformer.creates