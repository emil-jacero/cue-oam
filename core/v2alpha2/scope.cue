package v2alpha2

// Scope definition
#Scope: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Scope"
	#metadata: #ScopeMeta & {
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	affects: [...#Component]
	#Trait
}

// Scope metadata
#ScopeMeta: {
	#id:  #NameType
	name: #NameType | *#id
	...
}
