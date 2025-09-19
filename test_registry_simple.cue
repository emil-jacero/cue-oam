package test

import (
	core "jacero.io/oam/core/v2alpha2"
	traits "jacero.io/oam/catalog/traits/core/v2alpha2"
)

// Check the registry
// registry: core.#TraitRegistry & traits.#TraitRegistry

// Count of registered traits
// registryCount: len(core.#TraitRegistry)

// Test resolution of Replicas trait
testResolveReplicas: core.#ResolveTraitSchema & {
	traitName: "core.oam.dev/v2alpha2.Replicas"
	_registry: traits.#TraitRegistry
}
