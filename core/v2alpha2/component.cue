package v2alpha2

// Component definition
#Component: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Component"
	#metadata: #ComponentMeta & {
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	#Trait
}

// Component metadata
#ComponentMeta: {
	#id:  #NameType
	name: #NameType | *#id
	...
}
