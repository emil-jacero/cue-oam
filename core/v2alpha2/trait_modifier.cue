package v2alpha2

#TraitMetaModifier: #TraitMetaBase & {
	#kind!: string
	type:   "modifier"

	// The domains of this trait
	// Can be one or more of "workload", "data", "connectivity", "security", "observability", "governance"
	// Modifier traits can affect multiple domains
	domains!: [...#TraitDomain]

	// Dependencies on other traits
	// Lists traits that must be present for this trait to function
	// Used for modifier traits that patch resources created by other traits
	dependencies?: [...#TraitMetaAtomic | #TraitMetaComposite] & [_, ...]
}
