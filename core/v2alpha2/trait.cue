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
//// Policy Trait Domains
////////////////////////////////////////////////////////////////////////////////////////////////////////

#PolicyTraitDomain: "security" | "contractual" | "compliance" | "operational"

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
			#kind!: traitName
			...
		}
	}

	// Trait-specific fields
	...
}

#TraitMetaAtomic: #TraitMetaBase & {
	#apiVersion:      string
	#kind!:            string
	#combinedVersion: "\(#apiVersion).\(#kind)"
	type:  "atomic"

	// The domain of this trait
	// Can be one of "operational", "structural", "behavioral", "resource", "contractual", "security", "observability", "integration"
	domain!: #TraitDomain

	requiredCapability: string | *#combinedVersion
}

#TraitMetaComposite: #TraitMetaBase & {
	#apiVersion:      string
	#kind!: string
	#combinedVersion: "\(#apiVersion).\(#kind)"
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
	// Validations
	///////////////////////////////////////////////////////////////////////
	
	// Validation 1: Ensure composes list is not empty
	#validateComposesNotEmpty: len(composes) > 0 | error("Composite trait must compose at least one trait")
	
	// Validation 2: Calculate composition depth
	#compositionDepth: {
		let depths = [
			for trait in composes {
				if trait.type == "atomic" { 1 }
				if trait.type == "composite" && trait._compositionDepth != _|_ { trait._compositionDepth + 1 }
				if trait.type == "composite" && trait._compositionDepth == _|_ { 2 }
			},
		]
		if len(depths) > 0 { list.Max(depths) }
		if len(depths) == 0 { 0 }
	}
	
	// Validation 3: Ensure composition depth doesn't exceed 3
	#validateCompositionDepth: #compositionDepth <= 3 | error("Composition depth cannot exceed 3 levels. Current depth: \(#compositionDepth)")
	
	// Collect all directly composed trait combinedVersions
	_directComposedCombinedVersions: [
		for trait in composes {
			trait.#combinedVersion
		},
	]

	// Build a set of all trait combinedVersions in the composition hierarchy
	_allComposedCombinedVersions: {
		// Start with direct compositions
		let direct = _directComposedCombinedVersions

		// Add nested compositions for composite traits
		let nested = [
			for trait in composes if trait.type == "composite" && trait._allComposedCombinedVersions != _|_ {
				for k in trait._allComposedCombinedVersions { k }
			},
		]
		
		// Combine and deduplicate
		let all = list.Concat([direct, nested])
		let set = { for k in all { (k): _ } }
		[for k, _ in set { k }]
	}
	
	// Validation 4: Ensure this trait doesn't compose itself (direct or indirect circular dependency)
	// Note: This only validates if the trait references are already defined and can form a cycle
	// In practice, CUE will prevent actual circular references at evaluation time
	#validateNoCircularDependency: {
		// Only check if we can determine the kind
		let hasCircular = list.Contains(_allComposedCombinedVersions, #combinedVersion)
		!hasCircular | error("Circular dependency detected: trait '\(#combinedVersion)' cannot compose itself directly or indirectly")
		if #combinedVersion == _|_ { true }
	}

}

#TraitMetaModifier: #TraitMetaBase & {
	#kind!: string
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
	#kind!:            string
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

