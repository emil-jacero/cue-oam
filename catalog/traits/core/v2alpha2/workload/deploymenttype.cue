package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// DeploymentType - Specifies the deployment pattern for the workload
// This is a validation trait, meaning it is referenced in the transformer but not
// directly applied to the workload.
// It will validate that the component has the correct deploymentType and fields set.
#DeploymentTypeMeta: #DeploymentType.#metadata.#traits.DeploymentType
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
		if type == "Deployment" {#TypeDeployment}

		if type == "StatefulSet" {#TypeStatefulSet}

		if type == "DaemonSet" {#TypeDaemonSet}

		if type == "Job" {#TypeJob}

		if type == "CronJob" {#TypeCronJob}

		if type == "Pod" {#TypePod}

		if type == "ReplicaSet" {#TypeReplicaSet}
	}
}

#DeploymentTypeSchema: {
	type: #DeploymentTypes

	#TypeDeployment | #TypeStatefulSet | #TypeDaemonSet | #TypeJob | #TypeCronJob | #TypePod | #TypeReplicaSet
}

#DeploymentTypes: string | *"Deployment" | "StatefulSet" | "DaemonSet" | "Job" | "CronJob" | "Pod" | "ReplicaSet"

// Deployment specific fields
#TypeDeployment: {
	type:                     "Deployment"
	revisionHistoryLimit?:    uint | *10
	progressDeadlineSeconds?: uint | *600
}

// StatefulSet specific fields
#TypeStatefulSet: {
	type:                     "StatefulSet"
	serviceName!:          string // Required for StatefulSet
	podManagementPolicy?:  "OrderedReady" | "Parallel" | *"OrderedReady"
	revisionHistoryLimit?: uint | *10
	persistentVolumeClaimRetentionPolicy?: {
		whenDeleted?: "Retain" | "Delete"
		whenScaled?:  "Retain" | "Delete"
	}
	rollingUpdate?: {
		partition?: uint | *0
	}
}

// DaemonSet specific fields
#TypeDaemonSet: {
	type:                     "DaemonSet"
}

// Job specific fields
#TypeJob: {
	type:                     "Job"
	completions?:             uint | *1
	parallelism?:             uint | *1
	backoffLimit?:            uint | *6
	ttlSecondsAfterFinished?: uint
	activeDeadlineSeconds?:   uint
	suspend?:                 bool | *false
	completionMode?:          "NonIndexed" | "Indexed" | *"NonIndexed"
}

// CronJob specific fields
#TypeCronJob: {
	schedule!:                   string // Required for CronJob (e.g., "0 2 * * *")
	successfulJobsHistoryLimit?: uint | *3
	failedJobsHistoryLimit?:     uint | *1
	startingDeadlineSeconds?:    uint
	concurrencyPolicy?:          "Allow" | "Forbid" | "Replace" | *"Allow"
	suspend?:                    bool | *false
	timeZone?:                   string // Kubernetes 1.25+
}

// Pod specific fields
#TypePod: {
	type: "Pod"
}

// ReplicaSet specific fields
#TypeReplicaSet: {
	type: "ReplicaSet"
}
