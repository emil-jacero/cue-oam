package v2alpha2

#TraitMetaAtomic: #TraitMetaBase & {
	#apiVersion:      string
	#kind!:           string
	#combinedVersion: "\(#apiVersion).\(#kind)"
	type:             "atomic"

	// The domain of this trait
	// Can be one of "workload", "data", "connectivity", "security", "observability", "governance"
	domain!: #TraitDomain

	requiredCapability: string | *#combinedVersion
}
