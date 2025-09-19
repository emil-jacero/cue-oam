package v2alpha2

// Central trait registry - traits self-register here
// Each trait adds itself to this list during package loading
#TraitRegistry: [...#Trait]

// Helper to resolve trait schema by name from registry
#ResolveTraitSchema: {
	traitName: string

	// Find trait in registry by fullyQualifiedName
	let matchingTraits = [
		for trait in #TraitRegistry
		if trait.#metadata.#traits != _|_ {
			for _, traitMeta in trait.#metadata.#traits
			if traitMeta.#fullyQualifiedName == traitName {
				traitMeta.schema
			}
		}
	]

	schema: {
		if len(matchingTraits) > 0 {
			matchingTraits[0]
		}
	}
}