package v3alpha1

// Application definition
#Application: #Object & {
	#kind: "Application"
	#metadata: {
		#CommonObjectMeta

		// The namespace the application is deployed in
		namespace?: #NamespaceType | *"default"

		// The version of the application. Must follow semver
		version: string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

		// Applications are able to apply extra labels and annotations
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}

	// Components in this application
	components!: [Id=string]: #Component & {
		#metadata: #id: Id
	}

	// // Scopes for grouping components
	// scopes?: [Id=string]: #Scope & {
	// 	#metadata: #id: Id
	// }

	// // Application-wide policies
	// policies?: [Id=string]: #Policy & {
	// 	#metadata: #id: Id
	// }

	// // Application configuration
	// config?: {
	// 	// Global environment variables
	// 	env?: [...#EnvVar]

	// 	// Global resource constraints
	// 	resources?: {
	// 		limits?: {...}
	// 		defaults?: {...}
	// 	}

	// 	// Deployment configuration
	// 	deployment?: {
	// 		strategy?: string
	// 		regions?: [...string]
	// 		environments?: [...string]
	// 	}
	// }
}

// // Bundle definition - groups multiple applications
// #Bundle: #Object & {
// 	#kind: "Bundle"
// 	#metadata: {
// 		#CommonObjectMeta
// 		version: #VersionType

// 		// Bundle-specific metadata
// 		author?:     string
// 		license?:    string
// 		homepage?:   string
// 		repository?: string
// 	}

// 	// Applications in this bundle
// 	applications!: [Id=string]: #Application & {
// 		#metadata: #id: Id
// 	}

// 	// Bundle-wide configuration
// 	config?: {...}
// }
