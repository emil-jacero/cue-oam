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
		provides: {workload: #Workload.workload}
	}

	workload: {
		// Container specifications
		containers: [string]: schema.#ContainerSpec & {
			// Main container must exist
			main?: {name: string | *#metadata.name}
		}

		// Container specifications with inheritance from defaults
		containers: [string]: schema.#ContainerSpec & {
			// Apply defaults if not specified at container level

			// Resources
			if resources == _|_ {
				resources: resources
			}
		}

		// Init containers that run before main containers
		initContainers?: [string]: schema.#ContainerSpec

		// Ephemeral containers for debugging (K8s 1.23+)
		ephemeralContainers?: [string]: schema.#ContainerSpec & {
			targetContainerName?: string // Container to share process namespace with
		}

		// Scaling configuration (replaces #Replica trait)
		scaling: {
			replicas?: uint | *1

			// Min/max for autoscaling integration
			minReplicas?: uint | *1
			maxReplicas?: uint | *10

			// Scaling behavior hints
			scaleDownStabilizationWindowSeconds?: uint | *300
			scaleUpStabilizationWindowSeconds?:   uint | *0
		}

		// Restart policy (replaces #RestartPolicy trait)
		restartPolicy: "Always" | "OnFailure" | "Never" | *"Always"

		// Update strategy (replaces #UpdateStrategy trait)
		updateStrategy?: {
			type: "RollingUpdate" | "Recreate" | *"RollingUpdate"

			// Rolling update configuration
			if type == "RollingUpdate" {
				rollingUpdate?: {
					maxSurge?:       uint | string | *"25%"
					maxUnavailable?: uint | string | *"25%"
					partition?:      uint // For StatefulSet-like behavior
				}
			}
		}

		// Pod lifecycle settings
		lifecycle?: {
			// Termination grace period in seconds
			terminationGracePeriodSeconds?: uint | *30

			// Active deadline for Jobs
			activeDeadlineSeconds?: uint

			// Restart limits
			backoffLimit?: uint | *6 // For Jobs

			// Progress deadline for deployments
			progressDeadlineSeconds?: uint | *600
		}

		// Scheduling and placement
		scheduling?: {
			// Node selection
			nodeSelector?: {[string]: string}

			// Node affinity
			nodeAffinity?: {
				required?: [...{
					key:      string
					operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
					values?: [...string]
				}]
				preferred?: [...{
					weight: uint & >=1 & <=100
					preference: {
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
						values?: [...string]
					}
				}]
			}

			// // Pod affinity/anti-affinity
			// podAffinity?: {
			// 	required?: [...#PodAffinityTerm]
			// 	preferred?: [...{
			// 		weight:          uint & >=1 & <=100
			// 		podAffinityTerm: #PodAffinityTerm
			// 	}]
			// }

			// podAntiAffinity?: {
			// 	required?: [...#PodAffinityTerm]
			// 	preferred?: [...{
			// 		weight:          uint & >=1 & <=100
			// 		podAffinityTerm: #PodAffinityTerm
			// 	}]
			// }

			// Tolerations for taints
			tolerations?: [...{
				key?:               string
				operator?:          "Exists" | "Equal" | *"Equal"
				value?:             string
				effect?:            "NoSchedule" | "PreferNoSchedule" | "NoExecute"
				tolerationSeconds?: uint // For NoExecute
			}]

			// Topology spread constraints
			topologySpreadConstraints?: [...{
				maxSkew:           uint & >=1
				topologyKey:       string
				whenUnsatisfiable: "DoNotSchedule" | "ScheduleAnyway"
				labelSelector?: {[string]: string}
				minDomains?: uint & >=1
			}]

			// Priority class
			priorityClassName?: string
			priority?:          int32 // Direct priority value

			// Preemption policy
			preemptionPolicy?: "PreemptLowerPriority" | "Never" | *"PreemptLowerPriority"
		}

		// Security settings
		security?: {
			// Service account
			serviceAccountName?:           string
			automountServiceAccountToken?: bool | *true

			// Pod security context
			podSecurityContext?: {
				runAsUser?:           uint
				runAsGroup?:          uint
				runAsNonRoot?:        bool
				fsGroup?:             uint
				fsGroupChangePolicy?: "OnRootMismatch" | "Always"
				supplementalGroups?: [...uint]
				seccompProfile?: {
					type:              "RuntimeDefault" | "Unconfined" | "Localhost"
					localhostProfile?: string // When type is Localhost
				}
				seLinuxOptions?: {
					level?: string
					role?:  string
					type?:  string
					user?:  string
				}
				sysctls?: [...{
					name:  string
					value: string
				}]
				windowsOptions?: {
					gmsaCredentialSpecName?: string
					gmsaCredentialSpec?:     string
					runAsUserName?:          string
					hostProcess?:            bool
				}
			}

			// Default container security context (applied to all containers)
			containerSecurityContext?: {
				allowPrivilegeEscalation?: bool | *false
				capabilities?: {
					add?: [...string]
					drop?: [...string] | *["ALL"]
				}
				privileged?:             bool | *false
				readOnlyRootFilesystem?: bool | *false
				runAsUser?:              uint
				runAsGroup?:             uint
				runAsNonRoot?:           bool | *true
				procMount?:              "Default" | "Unmasked"
			}
		}

		// Networking
		networking?: {
			// DNS configuration
			dnsPolicy?: "ClusterFirst" | "ClusterFirstWithHostNet" | "Default" | "None" | *"ClusterFirst"
			dnsConfig?: {
				nameservers?: [...string]
				searches?: [...string]
				options?: [...{
					name:   string
					value?: string
				}]
			}

			// Host networking options
			hostNetwork?: bool | *false
			hostPID?:     bool | *false
			hostIPC?:     bool | *false
			hostUsers?:   bool | *true

			// Hostname settings
			hostname?:          string
			subdomain?:         string
			setHostnameAsFQDN?: bool | *false

			// Host aliases
			hostAliases?: [...{
				ip: string
				hostnames: [...string]
			}]

			// Share process namespace
			shareProcessNamespace?: bool | *false
		}

		// Resource management
		resources?: schema.#ResourceRequirements

		// Runtime settings
		runtime?: {
			// Runtime class for specialized runtimes
			runtimeClassName?: string

			// Scheduler name
			schedulerName?: string | *"default-scheduler"

			// Enable service links
			enableServiceLinks?: bool | *true

			// Preferred during scheduling ignored during execution
			preferredDuringSchedulingIgnoredDuringExecution?: bool | *false
		}

		// Disruption management
		disruption: {
			// Pod disruption budget settings
			minAvailable?:   uint | string // Number or percentage
			maxUnavailable?: uint | string // Number or percentage

			// Unhealthy pod eviction policy
			unhealthyPodEvictionPolicy?: "IfHealthyBudget" | "AlwaysAllow" | *"IfHealthyBudget"
		}

		// Image pull settings
		imagePull: {
			// Image pull secrets
			secrets?: [...string]

			// Pull policy for all containers (can be overridden per container)
			policy?: "Always" | "IfNotPresent" | "Never" | *"IfNotPresent"
		}

		// Deployment type hint (helps provider choose resource type)
		deploymentType: "Deployment" | "StatefulSet" | "DaemonSet" | "Job" | "CronJob" | *"Deployment"

		if deploymentType == "Deployment" {
			replicas?: replicas.count
			strategy?: updateStrategy.type
			if updateStrategy.type == "RollingUpdate" {
				rollingUpdate?: updateStrategy.rollingUpdate
			}
		}

		// StatefulSet specific settings
		if deploymentType == "StatefulSet" {
			statefulSet?: {
				serviceName:          string // Required for StatefulSet
				podManagementPolicy?: "OrderedReady" | "Parallel" | *"OrderedReady"
				persistentVolumeClaimRetentionPolicy?: {
					whenDeleted?: "Retain" | "Delete" | *"Retain"
					whenScaled?:  "Retain" | "Delete" | *"Retain"
				}
				ordinals?: {
					start?: uint | *0
				}
			}
		}
		
		// DaemonSet specific settings
		if deploymentType == "DaemonSet" {
			daemonSet?: {
				updateStrategy?: *"OnDelete" | "RollingUpdate"
				if updateStrategy == "RollingUpdate" {
					rollingUpdate?: {
						maxUnavailable?: uint | string | *"25%"
					}
				}
			}
		}

		// Job specific settings
		if deploymentType == "Job" {
			job?: {
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
			}
		}

		// CronJob specific settings  
		if deploymentType == "CronJob" {
			cronJob?: {
				schedule:                    string // Cron expression
				timeZone?:                   string // IANA time zone
				startingDeadlineSeconds?:    uint
				concurrencyPolicy?:          "Allow" | "Forbid" | "Replace" | *"Allow"
				suspend?:                    bool | *false
				successfulJobsHistoryLimit?: uint | *3
				failedJobsHistoryLimit?:     uint | *1
			}
		}
	}
}
