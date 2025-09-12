package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// CronJob defines the properties and behaviors of a Kubernetes CronJob
#CronJob: core.#Trait & {
	#metadata: #traits: CronJob: core.#TraitMetaAtomic & {
		#kind:       "CronJob"
		description: "Kubernetes CronJob for running jobs on a scheduled basis"
		domain:      "workload"
		scope: ["component"]
		provides: {cronjob: schema.#CronJobSpec}
	}
	cronjob: schema.#CronJobSpec
}

#CronJobMeta: #CronJob.#metadata.#traits.CronJob
