package v2alpha2

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Definition
/////////////////////////////////////////////////////////////////////////////////////////////////////////
#Trait: {
	#metadata: {
		#traits: [traitName=string]: {
			#kind!: traitName
			...
		}
		...
	}
	// Trait-specific fields
	...
}

#TraitMetaBase: {
	#apiVersion:         string | *"core.oam.dev/v2alpha2"
	#kind!:              string
	#fullyQualifiedName: "\(#apiVersion).\(#kind)"

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
	// Must be compatible with OpenAPIv3 schema
	// TODO: Add validation to only allow one named struct per trait
	schema!: [string]: _
	...
}

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

#TraitDomainWorkload: "workload" // Traits that define application runtime and execution models, such as containers, replicas, and deployment strategies.

#TraitDomainData: "data" // Traits that manage state, configuration, and persistence, such as volumes, secrets, and databases.

#TraitDomainConnectivity: "connectivity" // Traits that handle networking, service discovery, and integration, such as services, ingress, and APIs.

#TraitDomainSecurity: "security" // Traits that provide protection, authentication, and authorization, such as RBAC, TLS, and security contexts.

#TraitDomainObservability: "observability" // Traits that enable monitoring, logging, and tracing for visibility into application behavior.

#TraitDomainGovernance: "governance" // Traits that enforce policies, constraints, and compliance requirements, such as quotas, SLAs, and retention policies.

#TraitDomain: #TraitDomainWorkload | #TraitDomainData | #TraitDomainConnectivity | #TraitDomainSecurity | #TraitDomainObservability | #TraitDomainGovernance

////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Trait Scopes
////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Description: Trait scopes define where a trait can be applied within the system.
//// They indicate whether a trait is relevant to individual components or broader scopes.
////////////////////////////////////////////////////////////////////////////////////////////////////////

#TraitScopeComponent: "component" // Traits that apply to individual components.

#TraitScopeScope: "scope" // Traits that apply to broader scopes, affecting multiple components or the entire application.

#TraitScopes: #TraitScopeComponent | #TraitScopeScope
