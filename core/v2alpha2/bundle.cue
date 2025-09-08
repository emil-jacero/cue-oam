package v2alpha2

#Bundle: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Bundle"
	#metadata: #ComponentMeta & {
		name:         #NameType
		namespace?:   #NameType
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	applications: [string]: #Application
	scopes: [string]:       #Scope
}
