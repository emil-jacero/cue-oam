package v3alpha1

// Provider interface
#Provider: {
	#apiVersion: "core.oam.dev/v3alpha1"
	#kind:       "Provider"
	#metadata: {
		name:        string // The name of the provider
		description: string // A brief description of the provider
		minVersion:  string // The minimum version of the provider
		capabilities: [...string] // What this provider supports
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
