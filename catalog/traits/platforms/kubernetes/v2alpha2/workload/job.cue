package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Job defines the properties and behaviors of a Kubernetes Job
#Job: core.#Trait & {
	#metadata: #traits: Job: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/batch/v1"
		#kind:       "Job"
		description: "Kubernetes Job for running batch or one-time tasks"
		domain:      "workload"
		scope: ["component"]
		provides: {job: schema.#JobSpec}
	}
	job: schema.#JobSpec
}

#JobMeta: #Job.#metadata.#traits.Job

// Jobs defines the properties and behaviors of multiple Kubernetes Jobs
#Jobs: core.#Trait & {
	#metadata: #traits: Jobs: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/batch/v1"
		#kind:       "Jobs"
		description: "Kubernetes Jobs for running batch or one-time tasks"
		domain:      "workload"
		scope: ["component"]
		provides: {jobs: schema.#JobSpec}
	}
	jobs: [string]: schema.#JobSpec
}

#JobsMeta: #Jobs.#metadata.#traits.Jobs
