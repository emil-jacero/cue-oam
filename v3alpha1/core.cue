package v3alpha1

import (
	"strings"
)

//////////////////////////////////////////////
//// Core
//////////////////////////////////////////////

#NameType:      string & strings.MinRunes(1) & strings.MaxRunes(254)
#NamespaceType: string & strings.MinRunes(1) & strings.MaxRunes(254)
#LabelsType: [string]:      string | int | bool
#AnnotationsType: [string]: string | int | bool

#CommonObjectMeta: {
	#id:  #NameType
	name: #NameType | *#id
	...
}

#Object: {
	#apiVersion:      string | *"core.oam.dev/v3alpha1"
	#kind:            string & strings.MinRunes(1) & strings.MaxRunes(254)
	#combinedVersion: string | "\(#apiVersion).\(#kind)"
	#metadata:        #CommonObjectMeta
	...
}

#ComponentMeta: #CommonObjectMeta & {
	#traits!: [string]: {
		// Which trait this extends
		extends?: string
		// Optional tags to explain the functionality of the trait
		provides?: [...string]
		// Optional short description of the trait
		description?: string
        // Fields this trait exposes in its root.
        // Case sensitive as they must match the field (key) exactly.
        // The component processor will only extract these fields from the component
        fields!: [...string]
	}

	// The ID field is used to uniquely identify the trait in a component
	#id: #NameType

	// The name is a user-defined identifier for the trait. Defaults to the ID
	name: #NameType | *#id

	// Extra attributes a component inherit from all combined traits within it.
	attributes: {...}

	// Scopes are able to apply extra labels and annotations
	labels?:      #LabelsType
	annotations?: #AnnotationsType
	...
}

#ScopeTypes: string | #ScopeTypeNetwork | #ScopeTypeHealth | #ScopeTypeResource | #ScopeTypeSecurity | #ScopeTypeExecution | #ScopeTypeCustom
#ScopeTypeNetwork: "network" // Represents a network scope
#ScopeTypeHealth: "health" // Represents a health scope
#ScopeTypeResource: "resource" // Represents a resource scope
#ScopeTypeSecurity: "security" // Represents a security scope
#ScopeTypeExecution: "execution" // Represents an execution scope
#ScopeTypeCustom: "custom" // Represents a custom scope

#Scope: #Object & {
	#kind: "Scope"
	#metadata: {
		// The ID field is used to uniquely identify the scope in an application
		#id: #NameType

		// The name is a user-defined identifier for the scope. Defaults to the ID
		name: #NameType | *#id

		// Scopes are able to apply extra labels and annotations
		labels?:      #LabelsType
		annotations?: #AnnotationsType

        #scopes!: [string]: {
            // The type of the scope
            type: #ScopeTypes
            // Optional short description of the scope
            description?: string
        }
	}
	children: [...#Component]
	...
}

// Traits are reusable building blocks that encapsulate specific functionality or behavior.
#Trait: {
	#metadata: #ComponentMeta
	...
}

// Components are a collection of traits.
#Component: #Object & {
	#kind:     "Component"
	#metadata: #ComponentMeta
	traits: [string]: #Trait
}

// Applications are a collection of components, scopes and policies.
//
// Components in an application can depend on each other. For example a frontend component may depend on a backend component.
//
// Scopes can be used to group related components toghether. For example a shared network between components.
//
// Policies can be used to enforce specific rules and behaviors for an application.
// For example, a policy called "apply-once" could ensure that a particular component is only applied a single time.
#Application: #Object & {
	#kind: "Application"
	#metadata: {
		// The ID field is used to uniquely identify the application in a bundle
		#id: #NameType

		// The name is a user-defined identifier for the application. Defaults to the ID
		name: #NameType | *#id

		// The namespace the application is deployed in
		namespace?: #NamespaceType | *"default"

		// The version of the application. Must follow semver
		version: string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

		// Applications are able to apply extra labels and annotations
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}

	// components!: [string]: #Component
	components!: [Id=string]: #Component & {
		#metadata: #id: Id
	}
	scopes?: [Id=string]: #Scope & {
		#metadata: #id: Id
	}
}

// Bundles multiple applications together. Useful when developing and sharing a set of related applications.
#Bundle: #Object & {
	#kind: "Bundle"
	#metadata: {
		// The ID field is used to uniquely identify the bundle
		#id: #NameType

		// The name is a user-defined identifier for the bundle. Defaults to the ID
		name: #NameType | *#id

		// The version of the bundle. Must follow semver
		version: string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

		// Bundles are able to apply extra labels and annotations
		labels?:      #LabelsType
		annotations?: #AnnotationsType
	}
	applications!: [Id=string]: #Application & {
		#metadata: #id: Id
	}
}
