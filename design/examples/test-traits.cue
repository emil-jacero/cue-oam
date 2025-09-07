package examples

// This file tests the trait composition rules using the definitions from trait.cue

// Test atomic traits - these should work fine
testAtomicWorkload: #TraitMeta & {
	category: "operational"
	provides: workload: {}
	requires: ["core.oam.dev/v2alpha1.Runtime"]
	traitScope: ["component"]
}

testAtomicExposable: #TraitMeta & {
	category: "structural"
	provides: expose: {}
	requires: ["core.oam.dev/v2alpha1.NetworkProvider"]
	traitScope: ["component"]
}

testAtomicHealthCheck: #TraitMeta & {
	category: "behavioral"
	provides: health: {}
	requires: ["core.oam.dev/v2alpha1.HealthProvider"]
	traitScope: ["component"]
}

// Test valid composite trait - should work
testValidWebService: #TraitMeta & {
	category: "operational"
	composes: [
		testAtomicWorkload,
		testAtomicExposable,
		testAtomicHealthCheck,
	]
	provides: {
		workload: {}
		expose: {}
		health: {}
	}
	// NO requires field - automatically computed
	traitScope: ["component"]
}

// Verify the computed requirements
verifyWebServiceRequirements: {
	computed: testValidWebService.#computedRequires.out
	expected: [
		"core.oam.dev/v2alpha1.HealthProvider",
		"core.oam.dev/v2alpha1.NetworkProvider",
		"core.oam.dev/v2alpha1.Runtime",
	]
	isValid: computed == expected
}

// Test atomic trait with no requirements
testAtomicNoRequires: #TraitMeta & {
	category: "behavioral"
	provides: retry: {}
	// No requires field
	traitScope: ["component"]
}

verifyEmptyRequirements: {
	computed: testAtomicNoRequires.#computedRequires.out
	expected: []
	isValid: computed == expected
}

// Test composite with duplicate requirements (should deduplicate)
testAtomicStorage: #TraitMeta & {
	category: "resource"
	provides: storage: {}
	requires: ["core.oam.dev/v2alpha1.Runtime"] // Same as workload!
	traitScope: ["component"]
}

testCompositeWithDuplicates: #TraitMeta & {
	category: "resource"
	composes: [
		testAtomicWorkload, // requires Runtime
		testAtomicStorage,  // also requires Runtime
	]
	provides: {
		workload: {}
		storage: {}
	}
	traitScope: ["component"]
}

verifyDeduplication: {
	computed: testCompositeWithDuplicates.#computedRequires.out
	expected: ["core.oam.dev/v2alpha1.Runtime"]
	isValid:              computed == expected
	hasSingleRequirement: len(computed) == 1
}

// Summary of tests
testSummary: {
	atomicWorkload:   "✅ Atomic trait with requirements"
	atomicNoRequires: "✅ Atomic trait without requirements"
	validComposite:   "✅ Composite trait (auto-computed requirements)"

	webServiceRequirements: verifyWebServiceRequirements.isValid
	emptyRequirements:      verifyEmptyRequirements.isValid
	deduplicationWorks:     verifyDeduplication.isValid && verifyDeduplication.hasSingleRequirement

	allTestsPassed: webServiceRequirements && emptyRequirements && deduplicationWorks
}
