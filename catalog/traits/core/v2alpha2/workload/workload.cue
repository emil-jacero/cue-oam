package workload

import (
	// "strings"
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Workload - Defines a generic workload with container specifications
#WorkloadMeta: #Workload.#metadata.#traits.Workload

#Workload: core.#Trait & {
	#metadata: #traits: Workload: core.#TraitMetaAtomic & {
		#kind:       "Workload"
		description: "Comprehensive workload specification with containers, scaling, and lifecycle management"
		domain:      "workload"
		scope: ["component"]
		provides: workload: #WorkloadSchema
	}

	workload: #WorkloadSchema & {
		// Container specifications
		containers: [string]: schema.#ContainerSpec & {
			// Main container must exist
			main?: {name: string | *#metadata.name}
		}
	}
}

#WorkloadSchema: {
	// Container specifications
	containers: [string]: schema.#ContainerSpec

	// Init containers that run before main containers
	initContainers?: [string]: schema.#ContainerSpec

	// Restart policy (replaces #RestartPolicy trait)
	restartPolicy: "Always" | "OnFailure" | "Never" | *"Always"

	// Update strategy (replaces #UpdateStrategy trait)
	updateStrategy?: {
		type: "RollingUpdate" | "Recreate" | *"RollingUpdate"

		// Rolling update configuration
		rollingUpdate?: {
			maxSurge?:       uint | string | *"25%"
			maxUnavailable?: uint | string | *"25%"
			partition?:      uint // For StatefulSet-like behavior
		}
	}

	// Resource management
	resources?: schema.#ResourceRequirements

	// Scaling configuration (replaces #Scale trait)
	replicas?: uint | *1

	// Deployment type hint (helps provider choose resource type)
	#deployment | #statefulSet | #daemonSet | #job | #cronJob

}

// Deployment specific settings
#deployment: {
	updateStrategy?: *"Recreate" | "RollingUpdate"
	rollingUpdate?: {
		maxSurge?:       uint | string | *"25%"
		maxUnavailable?: uint | string | *"25%"
	}
	restartPolicy?: *"Always" | "OnFailure" | "Never"
}

// StatefulSet specific settings
#statefulSet: {
	serviceName:          string // Required for StatefulSet
	podManagementPolicy?: "OrderedReady" | "Parallel" | *"OrderedReady"
	persistentVolumeClaimRetentionPolicy?: {
		whenDeleted?: "Retain" | "Delete" | *"Retain"
		whenScaled?:  "Retain" | "Delete" | *"Retain"
	}
	ordinals?: {
		start?: uint | *0
	}
	restartPolicy?: *"Always" | "OnFailure" | "Never"
}

// DaemonSet specific settings
#daemonSet: {
	updateStrategy?: *"OnDelete" | "RollingUpdate"
	rollingUpdate?: {
		maxUnavailable?: uint | string | *"25%"
	}
	restartPolicy?: *"Always" | "OnFailure" | "Never"
}

// Job specific settings
#job: {
	completions?:             uint | *1
	parallelism?:             uint | *1
	completionMode?:          "NonIndexed" | "Indexed" | *"NonIndexed"
	ttlSecondsAfterFinished?: uint
	suspend?:                 bool | *false
	podFailurePolicy?: {
		rules: [...{
			action: "FailJob" | "Ignore" | "Count"
			onExitCodes?: {
				operator: "In" | "NotIn"
				values: [...int32]
			}
			onPodConditions?: [...{
				type:   string
				status: "True" | "False" | "Unknown"
			}]
		}]
	}
	restartPolicy?: *"Never" | "OnFailure"
}

// CronJob specific settings
#cronJob: {
	schedule:                    string // Cron expression
	timeZone?:                   string // IANA time zone
	startingDeadlineSeconds?:    uint
	concurrencyPolicy?:          "Allow" | "Forbid" | "Replace" | *"Allow"
	suspend?:                    bool | *false
	successfulJobsHistoryLimit?: uint | *3
	failedJobsHistoryLimit?:     uint | *1
	restartPolicy?:              *"Never" | "OnFailure"
}
