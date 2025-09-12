package workload

import (
	"strings"
	core "jacero.io/oam/core/v2alpha2"
	// schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
	conn "jacero.io/oam/catalog/traits/core/v2alpha2/connectivity"
)

// Workload - Defines a generic workload with container specifications
#WorkloadMeta: #Workload.#metadata.#traits.Workload

#Workload: core.#Trait & {
	#metadata: #traits: Workload: core.#TraitMetaComposite & {
		#kind:       "Workload"
		description: "Generic workload trait for defining containerized applications with deployment strategies and network exposure"
		domain:      "operational"
		scope: ["component"]
		composes: [
			#ContainerSetMeta,
			#ReplicaMeta,
			#RestartPolicyMeta,
			#UpdateStrategyMeta,
			conn.#ExposeMeta,
		]
		provides: {workload: #Workload.workload}
	}

	workload: {
		// Legacy interface for backward compatibility
		container:       #ContainerSet.containerSet.containers
		initContainers?: #ContainerSet.containerSet.init
		restart:         #RestartPolicy.restartPolicy
		replicas?:       #Replica.replica.count
		updateStrategy?: #UpdateStrategy.updateStrategy.type
		if #UpdateStrategy.updateStrategy.type == "RollingUpdate" {
			rollingUpdate?: #UpdateStrategy.updateStrategy.rollingUpdate
		}
		expose: conn.#Expose.expose

		// Deployment type for backward compatibility
		deploymentType?: *"Deployment" | "StatefulSet" | "DaemonSet"
		if deploymentType != _|_ {
			if deploymentType == "Deployment" {
				replicas?: replicas.count
				strategy?: updateStrategy.type
				if updateStrategy.type == "RollingUpdate" {
					rollingUpdate?: updateStrategy.rollingUpdate
				}
			}
			if deploymentType == "StatefulSet" {
				replicas?:            replicas.count
				serviceName!:         string & strings.MaxRunes(253)
				podManagementPolicy?: *"OrderedReady" | "Parallel"
				updateStrategy?:      *"OnDelete" | "RollingUpdate"
				if updateStrategy == "RollingUpdate" {
					rollingUpdate?: {
						partition?: uint | *0
					}
				}
			}
			if deploymentType == "DaemonSet" {
				updateStrategy?: *"OnDelete" | "RollingUpdate"
				if updateStrategy == "RollingUpdate" {
					rollingUpdate?: {
						maxUnavailable?: uint | *1
					}
				}
			}
		}
	}
}
