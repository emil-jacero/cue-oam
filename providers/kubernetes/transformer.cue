package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	traits "jacero.io/oam/catalog/traits/core/v2alpha2"
	"list"
	"strings"
)

// Enhanced transformer structure for Kubernetes resources
#Transformer: {
	// Resource type this transformer creates (replaces 'accepts')
	creates: string

	// Required OAM traits for this transformer to work
	required: [...string]

	// Optional OAM traits
	optional?: [...string]

	// Auto-generated defaults from optional trait schemas
	defaults: {
		// Resolve schemas from optional traits only
		for traitName in (optional | *[]) {
			let resolvedSchema = #ResolveTraitSchema & {name: traitName}
			if resolvedSchema.schema != _|_ {
				resolvedSchema.schema
			}
		}

		// Allow transformer-specific additional defaults
		...
	}

	// Validation rules (e.g., deploymentType must match)
	validates?: {
		deploymentType?: string
		[string]:        _
	}

	// Transform function
	transform: {
		component: core.#Component
		context:   core.#ProviderContext
		output: [...] // Kubernetes resources
	}
}

// Helper to resolve trait schema by name from registry
#ResolveTraitSchema: {
	name: string

	// Find trait in registry by fullyQualifiedName
	let matchingTraits = [
		for trait in traits.#TraitRegistry
		if trait.#fullyQualifiedName == name {
			trait.schema
		},
	]

	schema: {
		if len(matchingTraits) > 0 {
			matchingTraits[0]
		}
	}
}

// Helper function to validate component against transformer
#ValidateTransformer: {
	component:   core.#Component
	transformer: #Transformer

	let componentTraits = component.#metadata.#atomicTraits

	// Check required traits
	missingRequired: [
		for req in transformer.required
		if !list.Contains(componentTraits, req) {req},
	]

	// Check validation rules - simplified for now
	validationErrors: [...string]
	validationErrors: []

	valid: len(missingRequired) == 0 && len(validationErrors) == 0

	error?: string
	if !valid && len(missingRequired) > 0 {
		error: "Component cannot use transformer - Missing required traits: " + strings.Join(missingRequired, ", ")
	}
}
