package v2alpha2

import (
	"list"
)

////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Types
////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Description: Trait types categorize the nature and functionality of traits within the system.
//// They help in understanding how traits can be composed, modified, and applied to components or scopes
////////////////////////////////////////////////////////////////////////////////////////////////////////

#TraitTypeAtomic: "atomic" // The smallest unit of trait functionality. Cannot be decomposed further.

#TraitTypeComposite: "composite" // A trait built from multiple atomic or composite traits, providing combined functionality.

#TraitTypeModifier: "modifier" // A trait that modifies or enhances the behavior of other traits. Cannot stand alone.

#TraitTypeCustom: "custom" // A user-defined trait that does not fit into standard categories.

#TraitTypes: #TraitTypeAtomic | #TraitTypeComposite | #TraitTypeModifier | #TraitTypeCustom

////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Domains
////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Description: Trait domains classify traits based on their area of concern or functionality within the system.
//// They provide context on what aspect of a component or scope the trait influences.
////////////////////////////////////////////////////////////////////////////////////////////////////////

#TraitDomainOperational: "operational" // Traits that manage how components operate, such as scaling and deployment strategies.

#TraitDomainStructural: "structural" // Traits that define the structure or architecture of components, such as networking and exposure.

#TraitDomainBehavioral: "behavioral" // Traits that influence the behavior of components, such as scheduling and affinity.

#TraitDomainResource: "resource" // Traits that manage resources used by components, such as volumes and configurations.

#TraitDomainContractual: "contractual" // Traits that define contracts or agreements between components, such as service level objectives.

#TraitDomainSecurity: "security" // Traits that enhance the security posture of components, such as access controls and policies.

#TraitDomainObservability: "observability" // Traits that improve the observability of components, such as logging and monitoring.

#TraitDomainIntegration: "integration" // Traits that facilitate integration with external systems or services.

#TraitDomain: #TraitDomainOperational | #TraitDomainStructural | #TraitDomainBehavioral | #TraitDomainResource | #TraitDomainContractual | #TraitDomainSecurity | #TraitDomainObservability | #TraitDomainIntegration

////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Scopes
////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Description: Trait scopes define where a trait can be applied within the system.
//// They indicate whether a trait is relevant to individual components or broader scopes.
////////////////////////////////////////////////////////////////////////////////////////////////////////

#TraitScopeComponent: "component" // Traits that apply to individual components.

#TraitScopeScope: "scope" // Traits that apply to broader scopes, affecting multiple components or the entire application.

#TraitScopes: #TraitScopeComponent | #TraitScopeScope

////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Definitions
////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Description: Trait definitions provide the structure and metadata for defining traits.
//// They include atomic traits, composite traits, and the relationships between them.
////////////////////////////////////////////////////////////////////////////////////////////////////////
//#TraitMetaAtomic | #TraitMetaComposite | #TraitMetaModifier &
#Trait: {
	#metadata: {
		#id:  #NameType
		name: #NameType | *#id
		#traits: [traitName=string]: {
			#kind: traitName
			...
		}
	}

	// Trait-specific fields
	...
}

#TraitMetaAtomic: #TraitMetaBase & {
	#apiVersion:      string
	#kind:            string
	#combinedVersion: "\(#apiVersion).\(#kind)"

	type:  "atomic"

	// The domain of this trait
	// Can be one of "operational", "structural", "behavioral", "resource", "contractual", "security", "observability", "integration"
	domain!: #TraitDomain

	requiredCapability?: string | *#combinedVersion
}

#TraitMetaComposite: #TraitMetaBase & {
	#kind: string
	type:  "composite"

	// Composition - list of traits this trait is built from
	composes!: [...#TraitMetaAtomic | #TraitMetaComposite] & [_, ...]

	// The domains of this trait
	// Can be one or more of "operational", "structural", "behavioral", "resource", "contractual", "security", "observability", "integration"
	// Computed as the union of domains of composed traits
	domains: {
		// Gather items from both sources, only if they exist
		let items = [
			for trait in composes if trait.domain != _|_ { trait.domain },
			for trait in composes if trait.domains != _|_ {
				for d in trait.domains { d }
			},
		]

		// Deduplicate via map-keys, then sort for stable output
		let set = { for v in items { (v): _ } }
		list.SortStrings([for k, _ in set { k }])
	}

	// External dependencies (not composition)
	// For composite traits: automatically computed from composed traits
	// Computed as the union of requiredCapabilities of composed traits
	requiredCapabilities: {
		// Gather items from both sources, only if they exist
		let items = [
			for trait in composes if trait.type == "atomic" { trait.requiredCapability },
			for trait in composes if trait.type == "composite" {
				for rc in trait.requiredCapabilities { rc }
			},
		]

		// Deduplicate via map-keys, then sort for stable output
		let set = { for v in items { (v): _ } }
		list.SortStrings([for k, _ in set { k }])
	}


	///////////////////////////////////////////////////////////////////////

	// Composition depth tracking and validation
	// #compositionDepth: {
	// 	if len(composes) > 0 {
	// 		// Composite trait - maximum depth of composed traits + 1
	// 		composedDepths: [for trait in composes {trait.#compositionDepth.depth}]
	// 		maxDepth: list.Max(composedDepths)
	// 		depth:    maxDepth + 1
	// 	}
	// }

	// // Circular dependency detection
	// #circularDependencyCheck: {
	// 	if len(composes) == 0 {
	// 		// Empty composes - no circular dependencies
	// 		valid: true
	// 	}
	// 	if len(composes) > 0 {
	// 		// For now, we perform basic validation that doesn't create circular references
	// 		// This is a simplified check that ensures structural soundness
	// 		// More sophisticated cycle detection would require a different approach
	// 		valid: true
	// 	}
	// }

	// // Validation: composition depth cannot exceed 3 (atomic=0, max composite=3)
	// if len(composes) > 0 {
	// 	if #compositionDepth.depth > 3 {
	// 		error("Composition depth cannot exceed 3. Current depth: \(#compositionDepth.depth)")
	// 	}
	// }

	// // Validation: circular dependency detection
	// if len(composes) > 0 {
	// 	if !#circularDependencyCheck.valid {
	// 		error("Circular dependency detected in trait composition. Trait '\(#kind)' creates a cycle in the composition chain.")
	// 	}
	// }
}

#TraitMetaModifier: #TraitMetaBase & {
	#kind: string
	type: "modifier"

	// The domains of this trait
	// Can be one or more of "operational", "structural", "behavioral", "resource", "contractual", "security", "observability", "integration"
	// Computed as the union of domains of composed traits
	domains!: [...#TraitDomain]

	// Dependencies on other traits
	// Lists traits that must be present for this trait to function
	// Used for modifier traits that patch resources created by other traits
	dependencies?: [...#TraitMetaAtomic | #TraitMetaComposite] & [_, ...]
}

#TraitMetaBase: {
	#apiVersion:      string | *"core.oam.dev/v2alpha2"
	#kind:            string
	#combinedVersion: "\(#apiVersion).\(#kind)"

	// Human-readable description of the trait
	description?: string

	// Optional metadata labels and annotations
	labels?:      #LabelsType
	annotations?: #AnnotationsType

	// The type of this trait
	// Can be one of "atomic", "composite", "modifier", "custom"
	type!: #TraitTypes

	// Where can this trait be applied
	// Can be one or more of "component", "scope"
	scope!: [...#TraitScopes]

	// Fields this trait provides to a component, scope, or promise
	provides!: {...}
	...
}

