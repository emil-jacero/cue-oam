package examples

import (
	"strings"
)

// Base types and metadata definitions
#NameType:      string & strings.MinRunes(1) & strings.MaxRunes(254)
#NamespaceType: string & strings.MinRunes(1) & strings.MaxRunes(254)
#VersionType:   string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
#LabelsType: [string]:      string | int | bool
#AnnotationsType: [string]: string | int | bool

#TraitCategory: string | "component" | "scope" | "policy"

#TraitsMeta: {
	// Category designation
	category: #TraitCategory

	// Which fields this trait adds to a parent component, scope or policy.
	// Must be a list of CUE paths, e.g. workload: #Workload.workload
	provides!: [string]: {...}

	// Platform capabilities required by this trait to function.
	// Used to ensure that the target platform supports the trait.
	requires!: [...string]

	// Optionally, which trait this trait extends
	extends?: [...#TraitsMeta]

	// Optional short description of the trait
	description?: string

	...
}

#Trait: {
	#metadata: {
		#id:  #NameType
		name: #NameType | *#id
		#traits: [string]: #TraitsMeta
		...
	}

	// Trait-specific fields
	...
}

#ComponentTrait: #Trait & {
	#metadata: {
		#id:  #NameType
		name: #NameType | *#id
		#traits: [string]: #TraitsMeta & {
			category: "component"
		}
	}
	...
}

#ScopeTrait: #Trait & {
	#metadata: {
		#id:          #NameType
		name:         #NameType | *#id
		namespace?:   #NamespaceType
		labels?:      #LabelsType
		annotations?: #AnnotationsType
		#traits: [string]: #TraitsMeta & {
			category: "scope"
		}
	}
	...
}
