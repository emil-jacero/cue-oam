package v2alpha2

// Application definition
#Application: {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Application"
	#metadata: {
		name:         #NameType
		namespace?:   #NameType | *"default"
		version?:     #VersionType
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	components: [Id=string]: #Component & {
		#metadata: #id: Id
	}
	scopes: [Id=string]: #Scope & {
		#metadata: #id: Id
	}
}
