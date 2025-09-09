package v2alpha2

// Component definition
#Component: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Component"
	#metadata: {
		#id:          #NameType
		name:         #NameType | *#id
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	#Trait
}
