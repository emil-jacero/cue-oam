package v2alpha2

// Central trait registry - traits self-register here
// Collects all traits from #RegisteredTraits
// #TraitRegistry: {
// 	[string]: #Trait
// }
#TraitRegistry: [...#TraitMetaBase]

// Helper to resolve trait schema by name from registry
#ResolveTraitSchema: {
	traitName: string
	_registry: #TraitRegistry

	// Look up directly in #TraitRegistry
	schema: _
	for trait in _registry {
		if trait.#fullyQualifiedName == traitName {
			_t:     trait
			schema: _t.schema
		}
	}
}
