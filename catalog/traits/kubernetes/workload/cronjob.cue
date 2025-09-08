package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// CronJobTrait defines the properties and behaviors of a Kubernetes CronJob
#CronJobTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "CronJob"
	
	description: "Kubernetes CronJob for running jobs on a scheduled basis"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/batch/v1.CronJob",
	]
	
	provides: {
		cronjob: schema.CronJob
	}
}
#CronJob: core.#Trait & {
	#metadata: #traits: CronJob: #CronJobTrait
	cronjob: schema.CronJob
}
