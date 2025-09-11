package workload

import (
	batchv1 "cue.dev/x/k8s.io/api/batch/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Job is a kubernetes job resource with apiVersion and kind set to default values.
#Job: batchv1.#Job & {
	apiVersion: "batch/v1"
	kind:       "Job"
	metadata:   metav1.#ObjectMeta
	spec?:      batchv1.#JobSpec
	status?:    batchv1.#JobStatus
}

#JobSpec: batchv1.#JobSpec

#JobStatus: batchv1.#JobStatus
