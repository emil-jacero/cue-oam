package v2alpha2

// Scope definition
#Scope: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Scope"
	#metadata: {
		#id:          #NameType
		name:         #NameType | *#id
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	#Trait

	// A list of components affected by this scope
	appliesTo: [...#Component]
}
