package v2alpha2

import (
	"list"
)

#TraitMetaComposite: #TraitMetaBase & {
	#apiVersion:         string
	#kind!:              string
	#fullyQualifiedName: "\(#apiVersion).\(#kind)"
	type:                "composite"

	// Composition - list of traits this trait is built from
	composes!: [...#TraitMetaAtomic | #TraitMetaComposite] & [_, ...]

	// The domains of this trait
	// Can be one or more of "workload", "data", "connectivity", "security", "observability", "governance"
	// Computed as the union of domains of composed traits
	domains: {
		// Gather items from both sources, only if they exist
		let items = [
			for trait in composes if trait.domain != _|_ {trait.domain},
			for trait in composes if trait.domains != _|_ {
				for d in trait.domains {d}
			},
		]

		// Deduplicate via map-keys, then sort for stable output
		let set = {for v in items {(v): _}}
		list.SortStrings([for k, _ in set {k}])
	}

	// No longer need requiredCapabilities - collect #fullyQualifiedName from composed traits

	///////////////////////////////////////////////////////////////////////
	// Validations
	///////////////////////////////////////////////////////////////////////

	// Validation 1: Ensure composes list is not empty
	#validateComposesNotEmpty: len(composes) > 0 | error("Composite trait must compose at least one trait")

	// Validation 2: Calculate composition depth
	#compositionDepth: {
		let depths = [
			for trait in composes {
				if trait.type == "atomic" {1}
				if trait.type == "composite" && trait._compositionDepth != _|_ {trait._compositionDepth + 1}
				if trait.type == "composite" && trait._compositionDepth == _|_ {2}
			},
		]
		if len(depths) > 0 {list.Max(depths)}
		if len(depths) == 0 {0}
	}

	// Validation 3: Ensure composition depth doesn't exceed 3
	#validateCompositionDepth: #compositionDepth <= 3 | error("Composition depth cannot exceed 3 levels. Current depth: \(#compositionDepth)")

	// Collect all directly composed trait fullyQualifiedNames
	_directComposedFullyQualifiedNames: [
		for trait in composes {
			trait.#fullyQualifiedName
		},
	]

	// Build a set of all trait fullyQualifiedNames in the composition hierarchy
	_allComposedFullyQualifiedNames: {
		// Start with direct compositions
		let direct = _directComposedFullyQualifiedNames

		// Add nested compositions for composite traits
		let nested = [
			for trait in composes if trait.type == "composite" && trait._allComposedFullyQualifiedNames != _|_ {
				for k in trait._allComposedFullyQualifiedNames {k}
			},
		]

		// Combine and deduplicate
		let all = list.Concat([direct, nested])
		let set = {for k in all {(k): _}}
		[for k, _ in set {k}]
	}

	// Validation 4: Ensure this trait doesn't compose itself (direct or indirect circular dependency)
	// Note: This only validates if the trait references are already defined and can form a cycle
	// In practice, CUE will prevent actual circular references at evaluation time
	#validateNoCircularDependency: {
		// Only check if we can determine the kind
		let hasCircular = list.Contains(_allComposedFullyQualifiedNames, #fullyQualifiedName)
		!hasCircular | error("Circular dependency detected: trait '\(#fullyQualifiedName)' cannot compose itself directly or indirectly")
		if #fullyQualifiedName == _|_ {true}
	}

}
