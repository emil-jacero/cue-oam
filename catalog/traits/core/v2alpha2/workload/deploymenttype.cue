package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// DeploymentType - Specifies the deployment pattern for the workload
#DeploymentType: core.#Trait & {
	#metadata: #traits: DeploymentType: core.#TraitMetaAtomic & {
		#kind:       "DeploymentType"
		description: "Specifies the deployment pattern for the workload"
		domain:      "workload"
		scope: ["component"]
		// MUST be OpenAPIv3 compliant
		schema: deploymentType: #DeploymentTypeSchema
	}

	deploymentType: #DeploymentTypeSchema & {
		type: #DeploymentTypes

		// Type-specific configuration with defaults and validation
		if type == "Deployment" {
			revisionHistoryLimit?:    uint | *10
			progressDeadlineSeconds?: uint | *600
			// Deployment uses 'strategy' (not updateStrategy)
			strategy?: {
				type: "RollingUpdate" | "Recreate" | *"RollingUpdate"
				if type == "RollingUpdate" {
					rollingUpdate?: {
						maxSurge?:       uint | string | *"25%"
						maxUnavailable?: uint | string | *"25%"
					}
				}
			}
		}

		if type == "StatefulSet" {
			serviceName!:          string // Required for StatefulSet
			podManagementPolicy?:  "OrderedReady" | "Parallel" | *"OrderedReady"
			revisionHistoryLimit?: uint | *10
			// StatefulSet uses 'updateStrategy'
			updateStrategy?: {
				type: "RollingUpdate" | "OnDelete" | *"RollingUpdate"
				if type == "RollingUpdate" {
					rollingUpdate?: {
						partition?:      int | *0
						maxUnavailable?: uint | string
					}
				}
			}
			persistentVolumeClaimRetentionPolicy?: {
				whenDeleted?: "Retain" | "Delete" | *"Retain"
				whenScaled?:  "Retain" | "Delete" | *"Retain"
			}
		}

		if type == "DaemonSet" {
			revisionHistoryLimit?: uint | *10
			// DaemonSet uses 'updateStrategy'
			updateStrategy?: {
				type: "RollingUpdate" | "OnDelete" | *"RollingUpdate"
				if type == "RollingUpdate" {
					rollingUpdate?: {
						maxSurge?:       uint | string | *0
						maxUnavailable?: uint | string | *1
					}
				}
			}
			minReadySeconds?: uint | *0
		}

		if type == "Job" {
			completions?:             uint | *1
			parallelism?:             uint | *1
			backoffLimit?:            uint | *6
			ttlSecondsAfterFinished?: uint
			activeDeadlineSeconds?:   uint
			suspend?:                 bool | *false
			completionMode?:          "NonIndexed" | "Indexed" | *"NonIndexed"
		}

		if type == "CronJob" {
			schedule!:                   string // Required for CronJob (e.g., "0 2 * * *")
			successfulJobsHistoryLimit?: uint | *3
			failedJobsHistoryLimit?:     uint | *1
			startingDeadlineSeconds?:    uint
			concurrencyPolicy?:          "Allow" | "Forbid" | "Replace" | *"Allow"
			suspend?:                    bool | *false
			timeZone?:                   string // Kubernetes 1.25+
		}

		if type == "Pod" {
			// Pod doesn't have deployment-level configuration
			// It's a single instance workload
			restartPolicy?: "Always" | "OnFailure" | "Never" | *"Always"
		}
	}
}

#DeploymentTypeSchema: {
	type: #DeploymentTypes

	// All possible type-specific configuration fields (all optional in schema)

	// Deployment fields
	revisionHistoryLimit?:    uint
	progressDeadlineSeconds?: uint
	// Deployment uses 'strategy'
	strategy?: {
		type: "RollingUpdate" | "Recreate"
		rollingUpdate?: {
			maxSurge?:       uint | string
			maxUnavailable?: uint | string
		}
	}

	// StatefulSet and DaemonSet use 'updateStrategy'
	updateStrategy?: {
		type: "RollingUpdate" | "OnDelete"
		rollingUpdate?: {
			partition?:      int
			maxUnavailable?: uint | string
			maxSurge?:       uint | string
		}
	}

	// StatefulSet specific fields
	serviceName?:         string
	podManagementPolicy?: "OrderedReady" | "Parallel"
	persistentVolumeClaimRetentionPolicy?: {
		whenDeleted?: "Retain" | "Delete"
		whenScaled?:  "Retain" | "Delete"
	}

	// DaemonSet specific fields
	minReadySeconds?: uint

	// Job fields
	completions?:             uint
	parallelism?:             uint
	backoffLimit?:            uint
	ttlSecondsAfterFinished?: uint
	activeDeadlineSeconds?:   uint
	suspend?:                 bool
	completionMode?:          "NonIndexed" | "Indexed"

	// CronJob fields
	schedule?:                   string
	successfulJobsHistoryLimit?: uint
	failedJobsHistoryLimit?:     uint
	startingDeadlineSeconds?:    uint
	concurrencyPolicy?:          "Allow" | "Forbid" | "Replace"
	timeZone?:                   string

	// Pod fields
	restartPolicy?: "Always" | "OnFailure" | "Never"
}

#DeploymentTypes: "Deployment" | "StatefulSet" | "DaemonSet" | "Job" | "CronJob" | "Pod"

#DeploymentTypeMeta: #DeploymentType.#metadata.#traits.DeploymentType
