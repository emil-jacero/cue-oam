package workload

import (
	batchv1 "cue.dev/x/k8s.io/api/batch/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// CronJob is a kubernetes cronjob resource with apiVersion and kind set to default values.
#CronJob: batchv1.#CronJob & {
	apiVersion: "batch/v1"
	kind:       "CronJob"
	metadata:   metav1.#ObjectMeta
	spec?:      batchv1.#CronJobSpec
	status?:    batchv1.#CronJobStatus
}

#CronJobSpec: batchv1.#CronJobSpec

#CronJobStatus: batchv1.#CronJobStatus
