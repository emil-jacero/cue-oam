package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// JobTrait defines the properties and behaviors of a Kubernetes Job
#JobTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Job"

	description: "Kubernetes Job for running batch or one-time tasks"

	type:   "atomic"
	domain: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/batch/v1.Job",
	]

	provides: {
		job: schema.#JobSpec
	}
}
#Job: core.#Trait & {
	#metadata: #traits: Job: #JobTrait
	job: schema.#JobSpec
}

// JobsTrait defines the properties and behaviors of multiple Kubernetes Jobs
#JobsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Jobs"

	description: "Kubernetes Jobs for running batch or one-time tasks"

	type:   "atomic"
	domain: "operational"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/batch/v1.Job",
	]

	provides: {
		jobs: [string]: schema.#JobSpec
	}
}
#Jobs: core.#Trait & {
	#metadata: #traits: Jobs: #JobsTrait
	jobs: [string]: schema.#JobSpec
}
