package v2alpha2

import "list"

// Component definition
#Component: #Trait & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Component"
	#metadata: {
		#id:          #NameType
		name:         #NameType | *#id
		labels?:      #LabelsType
		annotations?: #AnnotationsType

		// Traits applied to this component
		#traits: [traitName=string]: {
			#kind!: traitName
			...
		}

		// Helper: Extract ALL atomic traits (recursively traverses composites)
		#atomicTraits: [...string]
		#atomicTraits: {
			// Collect all atomic capabilities
			let allCapabilities = [
				for traitName, traitMeta in #traits if traitMeta != _|_ {
					// Atomic traits contribute themselves
					if traitMeta.type == "atomic" {
						traitMeta.#fullyQualifiedName
					}
					// Composite traits: collect #fullyQualifiedName from composed traits
					if traitMeta.type == "composite" && traitMeta.composes != _|_ {
						for composedTrait in traitMeta.composes {
							composedTrait.#fullyQualifiedName
						}
					}
				}
			]

			// Deduplicate and sort
			let set = {for cap in allCapabilities {(cap): _}}
			list.SortStrings([for k, _ in set {k}])
		}
	}
	#Trait

	// Add fields from all traits applied to this component
	// Unifies the 'schema' fields from each trait
	for traitName, t in #metadata.#traits {
		t.schema
	}
}
