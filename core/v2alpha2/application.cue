package v2alpha2

#Application: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Application"
	#metadata: #ComponentMeta & {
		name:         #NameType
		namespace?:   #NameType
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	components: [string]: #Component
	scopes: [string]:     #Scope
}
