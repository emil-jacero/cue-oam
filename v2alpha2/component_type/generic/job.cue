package generic

import (
	"strings"

	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2generic "jacero.io/oam/v2alpha2/schema/generic"
)

#Task: v2alpha2core.#ComponentType & {
	#metadata: {
		name:        "task.component-type.core.oam.dev"
		type:        "task"
		description: "Describes short-lived, one-off, containerized tasks that run to completion at specified intervals or as single instances."
	}
	#schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"

		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"

		labels?: [string]:      string | int | bool
		annotations?: [string]: string | int | bool

		name!: string & strings.MaxRunes(253)

		// The container image to use.
		I=image: v2alpha2generic.#Image

		// Secrets to use when pulling the container image.
		IPS=imagePullSecrets?: [...v2alpha2generic.#Secret]

		// Command to run in the container.
		C=command?: [...string]

		// Arguments to pass to the command.
		A=args?: [...string]

		// List of environment variables to set in the container.
		E=env?: [...v2alpha2generic.#EnvVar]

		// Resources required by the container.
		// Requests describes the minimum amount of compute resources required.
		// If Requests is omitted for a container, it defaults to an implementation-defined value.
		// Limits describes the maximum amount of compute resources allowed.
		// If Limits is omitted for a container, it defaults to an implementation-defined value.
		// Requests cannot exceed Limits.
		R=resources?: v2alpha2generic.#ResourceRequirements

		// Specifies the maximum desired number of pods the job should run at any given time.
		// The actual number of pods running in steady state will be less than this number when ((.spec.completions - .status.successful) < .spec.parallelism),
		// i.e. when the work left to do is less than max parallelism. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/
		parallelism?: uint | *1

		// Specifies the number of retries before marking this job failed. Defaults to 6 
		backoffLimit?: uint | *6
		// Specifies the duration in seconds relative to the startTime that the job may be continuously active
		// before the system tries to terminate it; value must be positive integer.
		// If a Job is suspended (at creation or through an update),
		// this timer will effectively be stopped and reset when the Job is resumed again. 
		activeDeadlineSeconds?: uint
		// ttlSecondsAfterFinished limits the lifetime of a Job that has finished execution (either Complete or Failed).
		// If this field is set, ttlSecondsAfterFinished after the Job finishes, it is eligible to be automatically deleted.
		// When the Job is being deleted, its lifecycle guarantees (e.g. finalizers) will be honored.
		// If this field is unset, the Job won't be automatically deleted.
		// If this field is set to zero, the Job becomes eligible to be deleted immediately after it finishes. 
		ttlSecondsAfterFinished?: uint

		// successPolicy specifies the policy when the Job can be declared as succeeded.
		// If empty, the default behavior applies - the Job is declared as succeeded only when the number of succeeded
		// pods equals to the completions. When the field is specified, it must be immutable and works only for the Indexed Jobs.
		// Once the Job meets the SuccessPolicy, the lingering pods are terminated.
		//
		// This field is beta-level. To use this field, you must enable the `JobSuccessPolicy` feature gate (enabled by default). 
		successPolicy?: v2alpha2generic.#JobSuccessPolicy

		// For Jobs, only Never/OnFailure make sense.
		container: v2alpha2generic.#ContainerSpec & {
			restartPolicy:    _ | *"Never" | "OnFailure"
			image:            I
			imagePullSecrets: IPS
			command:          C
			args:             A
			env:              E
			resources:        R
		}
	}
}
