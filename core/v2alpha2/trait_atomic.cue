package v2alpha2

#TraitMetaAtomic: #TraitMetaBase & {
	#apiVersion:      string
	#kind!:           string
	#combinedVersion: "\(#apiVersion).\(#kind)"
	type:             "atomic"

	// The domain of this trait
	// Can be one of "workload", "data", "connectivity", "security", "observability", "governance"
	domain!: #TraitDomain

	// The capability this trait requires from the underlying platform.
	// e.g. "core.oam.dev/v2alpha2.Workload"
	// Defaults to the combined version of apiVersion and kind
	requiredCapability: string | *#combinedVersion
}
