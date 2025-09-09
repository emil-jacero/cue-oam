package v2alpha2

// Provider interface
#Provider: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Provider"
	#metadata: {
		name:        string // The name of the provider
		description: string // A brief description of the provider
		minVersion:  string // The minimum version of the provider
		capabilities: [...string] // What this provider supports

		// Optional: Core traits that create primary resources - MUST be supported
		// If these are missing transformers, the provider should error
		coreTraits?: [...string]

		// Optional: Modifier traits that depend on other traits - can be safely ignored if unsupported
		// These traits modify resources created by core traits
		modifierTraits?: [...string]

		// Allow additional provider-specific metadata
		...
	}

	// Transformer registry - maps traits to transformers
	transformers: [string]: #Transformer

	// Render function
	render: {
		app:    #Application
		output: _ // Provider-specific output format
	}
}

// Transformer interface
#Transformer: {
	accepts: string // Trait name
	transform: {
		input:   _
		context: #ProviderContext
		output:  _
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
