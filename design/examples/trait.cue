package examples

import (
	"strings"
	"list"
)

// Base types and metadata definitions
#NameType:      string & strings.MinRunes(1) & strings.MaxRunes(254)
#VersionType:   string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
#LabelsType: [string]:      string | int | bool
#AnnotationsType: [string]: string | int | bool

#TraitCategory: "operational" | "structural" | "behavioral" | "resource" | "contractual"
#TraitScope: "component" | "scope" | "bundle" | "promise"

#TraitMeta: {
	name: 	  #NameType

	// What kind of trait this is, based on where it can be applied
	traitScope: [...#TraitScope]

    // The architectural scope where this trait operates (component, scope, bundle, or promise)
    category: #TraitCategory
    
    // Composition - list of traits this trait is built from
    // Presence of this field makes it a composite trait
    // Absence makes it an atomic trait
    composes?: [...#TraitMeta]
    
    // fields this trait provides to a component, application, scope, bundle, or promise
    provides: {...}
    
    // External dependencies (not composition)
    // For atomic traits: manually specified
    // For composite traits: automatically computed from composed traits
    requires?: [...string]
    
    // Computed requirements for composite traits
    #computedRequires: {
        if composes == _|_ {
            // Atomic trait - use manually specified requires
            if requires == _|_ {
                out: []
            }
            if requires != _|_ {
                out: requires
            }
        }
        if composes != _|_ {
            if len(composes) == 0 {
                // Empty composes list - treat as atomic
				type: "atomic"
                if requires == _|_ {
                    out: []
                }
                if requires != _|_ {
                    out: requires
                }
            }
            if len(composes) > 0 {
                // Composite trait - compute from composed traits
				type: "composite"
                allRequirements: list.FlattenN([
                    for composedTrait in composes {
                        composedTrait.#computedRequires.out
                    }
                ], 1)
                
                // Deduplicate requirements using unique list pattern
                deduped: [ for i, x in allRequirements if !list.Contains(list.Drop(allRequirements, i+1), x) {x}]
                
                // Sort the deduplicated requirements
                out: list.Sort(deduped, list.Ascending)
            }
        }
    }
    
    // Validation: composite traits should not manually specify requires
	if composes != _|_  {
		if len(composes) > 0 && requires != _|_ {
			error("Composite traits should not manually specify 'requires' - they are computed automatically")
		}

		// Validation: composite traits can only compose atomic traits
		if len(composes) > 0 {
			for i, composedTrait in composes {
				// Each composed trait must be atomic (no composes field or empty composes)
				if (composedTrait.composes & [...]) != _|_ {
					if len(composedTrait.composes & [...]) > 0 {
						error("Composite trait can only compose atomic traits. Trait at index \(i) is composite (has composes field)")
					}
				}
			}
		}
	}
}

#Trait: {
	#metadata: #ComponentMeta & {
        #traits: [traitName=string]: #TraitMeta & {
            name: traitName
        }
    }

	// Trait-specific fields
	...
}

