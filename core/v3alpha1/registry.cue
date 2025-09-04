// File: oam/core/v3alpha1/registry.cue
package v3alpha1

import (
	"list"
)

// Global trait registry
#TraitRegistry: {
	traits: [string]: #Trait

	// Get trait by name
	get: {
		name: string
		if traits[name] != _|_ {
			trait: traits[name]
		}
	}

	// List traits that provide a capability
	listByCapability: {
		capability: string
		result: [for name, trait in traits
			if list.Contains(trait.#metadata.provides, capability) {
				name
			},
		]
	}

	// Validate trait compatibility
	validateCompatibility: {
		trait1: string
		trait2: string

		_t1: traits[trait1]
		_t2: traits[trait2]

		compatible: {
			// Check if traits are explicitly compatible
			if _t1.#metadata.compose.incompatible != _|_ {
				!list.Contains(_t1.#metadata.compose.incompatible, trait2)
			}
			if _t2.#metadata.compose.incompatible != _|_ {
				!list.Contains(_t2.#metadata.compose.incompatible, trait1)
			}
		}
	}
}

// // Component registry for tracking component definitions
// #ComponentRegistry: {
// 	components: [string]: #Component

// 	// Register component
// 	register: {
// 		id:        string
// 		component: #Component
// 		components: {
// 			"\(id)": component
// 		}
// 	}

// 	// Find components with specific trait
// 	findByTrait: {
// 		trait: string
// 		result: [for id, comp in components
// 			if comp.#metadata.#traits[trait] != _|_ {
// 				id
// 			},
// 		]
// 	}

// 	// Validate component dependencies
// 	validateDependencies: {
// 		component: #Component
// 		errors: [...string]

// 		_errors: [for dep in component.#metadata.dependencies
// 			if components[dep.component] == _|_ {
// 				"Component '\(dep.component)' not found"
// 			},
// 		]

// 		if len(_errors) > 0 {
// 			errors: _errors
// 		}
// 	}
// }
