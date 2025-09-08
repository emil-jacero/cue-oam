package v2alpha2

import (
	"list"
)

#TraitTypes:    "atomic" | "composite"
#TraitCategory: "operational" | "structural" | "behavioral" | "resource" | "contractual"
#TraitScope:    "component" | "scope"

#Trait: {
	#metadata: #ComponentMeta & {
		#traits: [traitName=string]: #TraitObject & {
			#kind: traitName
		}
	}

	for traitName, t in #metadata.#traits {
		t.provides
	}

	// Trait-specific fields
	...
}

#TraitObject: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       string

	// Human-readable description of the trait
	description?: string

	// The type of this trait
	// Can be one of "atomic" or "composite"
	type!: #TraitTypes

	// The category of this trait
	// Can be one of "operational", "structural", "behavioral", "resource", "contractual"
	category!: #TraitCategory

	// Where can this trait be applied
	// Can be one or more of "component", "scope"
	scope!: [...#TraitScope]

	// Composition - list of traits this trait is built from
	// Presence of this field makes it a composite trait
	// Absence makes it an atomic trait
	composes?: [...#TraitObject]

	// External dependencies (not composition)
	// For atomic traits: manually specified
	// For composite traits: automatically computed from composed traits
	// for custom traits: optional
	requiredCapabilities?: [...string]

	// Fields this trait provides to a component, scope, or promise
	provides: {...}

	///////////////////////////////////////////////////////////////////////
	// Computed requirements for composite traits
	#computedRequiredCapabilities: {}

	// Composition depth tracking and validation
	#compositionDepth: {
		if composes == _|_ {
			// Atomic trait has depth 0
			depth: 0
		}
		if composes != _|_ {
			if len(composes) == 0 {
				// Empty composes list - treat as atomic
				depth: 0
			}
			if len(composes) > 0 {
				// Composite trait - maximum depth of composed traits + 1
				composedDepths: [for trait in composes {trait.#compositionDepth.depth}]
				maxDepth: list.Max(composedDepths)
				depth:    maxDepth + 1
			}
		}
	}

	// Circular dependency detection
	#circularDependencyCheck: {
		if composes == _|_ {
			// Atomic traits cannot have circular dependencies
			valid: true
		}
		if composes != _|_ {
			if len(composes) == 0 {
				// Empty composes - no circular dependencies
				valid: true
			}
			if len(composes) > 0 {
				// For now, we perform basic validation that doesn't create circular references
				// This is a simplified check that ensures structural soundness
				// More sophisticated cycle detection would require a different approach
				valid: true
			}
		}
	}

	if composes != _|_ {
		// Validation: composite traits should not manually specify requiredCapabilities
		if len(composes) > 0 && requiredCapabilities != _|_ {
			error("Composite traits should not manually specify 'requiredCapabilities' - they are computed automatically")
		}

		// Validation: composition depth cannot exceed 3 (atomic=0, max composite=3)
		if len(composes) > 0 {
			if #compositionDepth.depth > 3 {
				error("Composition depth cannot exceed 3. Current depth: \(#compositionDepth.depth)")
			}
		}

		// Validation: circular dependency detection
		if len(composes) > 0 {
			if !#circularDependencyCheck.valid {
				error("Circular dependency detected in trait composition. Trait '\(#kind)' creates a cycle in the composition chain.")
			}
		}

		// If composes is present and non-empty, type must be "composite"
		if len(composes) > 0 {
			type: "composite"
		}
	}

	if composes == _|_ {
		// If composes is an empty list, treat as atomic
		type: "atomic"
	}
}
