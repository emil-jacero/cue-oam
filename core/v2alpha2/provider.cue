package v2alpha2

import (
	"list"
	"strings"
)

// Provider interface
#Provider: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Provider"
	#metadata: {
		name:        string // The name of the provider
		description: string // A brief description of the provider
		minVersion:  string // The minimum version of the provider

		// Allow additional provider-specific metadata
		...
	}

	// Transformer registry - maps traits to transformers
	transformers: [string]: #Transformer | *null // null means explicitly unsupported

	// Render function
	render: {
		app:    #Application
		output: _ // Provider-specific output format
	}
}

// Enhanced transformer interface - generic for all providers
#Transformer: {
	// Resource type this transformer creates
	creates: string

	// Required OAM traits for this transformer to work
	required: [...string]

	// Optional OAM traits
	optional?: [...string]

	// Trait registry - must be populated by provider implementation
	registry: #TraitRegistry

	// Auto-generated defaults from optional trait schemas
	defaults: {
		// Resolve schemas from optional traits only
		for traitName in (optional | *[]) {
			let resolvedSchema = #ResolveTraitSchema & {
				name: traitName
				_registry: registry
			}
			if resolvedSchema.schema != _|_ {
				resolvedSchema.schema
			}
		}

		// Allow transformer-specific additional defaults
		...
	}

	// Validation rules (e.g., deploymentType must match)
	validates?: {
		[string]: _
	}

	// Transform function
	transform: {
		component: #Component
		context:   #ProviderContext
		output:    _ // Provider-specific output format
	}
}

// Helper to resolve trait schema by name from registry
#ResolveTraitSchema: {
	name: string
	_registry: [..._] // Trait registry to search in

	// Find trait in registry by fullyQualifiedName
	let matchingTraits = [
		for trait in _registry
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
	component:   #Component
	transformer: #Transformer

	let componentTraits = component.#metadata.#atomicTraits

	// Check required traits
	missingRequired: [
		for req in transformer.required
		if !list.Contains(componentTraits, req) {req},
	]

	// Check validation rules
	validationErrors: [...string]
	validationErrors: []

	valid: len(missingRequired) == 0 && len(validationErrors) == 0

	error?: string
	if !valid && len(missingRequired) > 0 {
		error: "Component cannot use transformer - Missing required traits: " + strings.Join(missingRequired, ", ")
	}
}

// Provider context passed to transformers
// Can be constructed manually or from Application + Component
#ProviderContext: {
	name:      string // Application name
	namespace: string // Application namespace
	capabilities: [...string] // Provider capabilities

	// Hierarchical metadata inheritance system
	metadata: {
		// Application-level metadata (applied to ALL resources in the application)
		application: {
			id:           string
			name:         string
			namespace:    string
			version:      string
			labels?:      #LabelsType
			annotations?: #AnnotationsType
		}

		// Component-level metadata (applied to all resources in this component)
		component: {
			id:           string
			name:         string
			labels?:      #LabelsType
			annotations?: #AnnotationsType
		}
	}
}
