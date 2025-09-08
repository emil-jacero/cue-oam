package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

#Job: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Job"
	
	description: "Kubernetes Job for running batch or one-time tasks"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/batch/v1.Job",
	]
	
	provides: {
		job: {
			// Job metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Job specification
			spec: {
				// Parallelism specifies the maximum desired number of pods running at any given time
				parallelism?: int32
				
				// Completions specifies the desired number of successfully finished pods
				completions?: int32
				
				// ActiveDeadlineSeconds specifies the duration in seconds relative to the job creation
				activeDeadlineSeconds?: int64
				
				// PodFailurePolicy describes how failed pods influence the handling of retries
				podFailurePolicy?: {
					rules: [...{
						action: "FailJob" | "Ignore" | "Count"
						onExitCodes?: {
							containerName?: string
							operator: "In" | "NotIn"
							values: [...int32]
						}
						onPodConditions: [...{
							type: string
							status: "True" | "False" | "Unknown"
						}]
					}]
				}
				
				// BackoffLimit specifies the number of retries before marking this job failed
				backoffLimit?: int32
				
				// BackoffLimitPerIndex specifies the limit for the number of retries within an index
				backoffLimitPerIndex?: int32
				
				// MaxFailedIndexes specifies the maximal number of failed indexes
				maxFailedIndexes?: int32
				
				// Selector is a label query over pods that should match the pod count
				selector?: {
					matchLabels: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}
				
				// ManualSelector controls generation of pod labels and pod selectors
				manualSelector?: bool
				
				// Template describes the pod that will be created
				template: {
					metadata: {
						labels: [string]:      string
						annotations: [string]: string
					}
					spec: {
						containers: [...{
							name:  string
							image: string
							imagePullPolicy?: "Always" | "Never" | "IfNotPresent"
							command?: [...string]
							args?: [...string]
							workingDir?: string
							
							ports?: [...{
								name?:          string
								containerPort:  uint & >=1 & <=65535
								hostPort?:      uint & >=1 & <=65535
								protocol?:      "TCP" | "UDP" | "SCTP"
								hostIP?:        string
							}]
							
							env?: [...{
								name:  string
								value?: string
								valueFrom?: {
									fieldRef?: {
										fieldPath: string
										apiVersion?: string
									}
									resourceFieldRef?: {
										resource: string
										containerName?: string
										divisor?: string
									}
									configMapKeyRef?: {
										name: string
										key:  string
										optional?: bool
									}
									secretKeyRef?: {
										name: string
										key:  string
										optional?: bool
									}
								}
							}]
							
							envFrom?: [...{
								prefix?: string
								configMapRef?: {
									name: string
									optional?: bool
								}
								secretRef?: {
									name: string
									optional?: bool
								}
							}]
							
							resources?: {
								limits?: {
									cpu?:    string
									memory?: string
									[string]: string
								}
								requests?: {
									cpu?:    string
									memory?: string
									[string]: string
								}
							}
							
							volumeMounts?: [...{
								name:      string
								mountPath: string
								subPath?: string
								readOnly?: bool
							}]
							
							livenessProbe?: #Probe
							readinessProbe?: #Probe
							startupProbe?: #Probe
							
							lifecycle?: {
								postStart?: #Handler
								preStop?: #Handler
							}
							
							terminationMessagePath?: string
							terminationMessagePolicy?: "File" | "FallbackToLogsOnError"
							
							securityContext?: #SecurityContext
						}]
						
						initContainers?: [...{
							// Same structure as containers
							name:  string
							image: string
							// ... (same fields as containers)
						}]
						
						volumes?: [...{
							name: string
							
							// Volume sources
							emptyDir?: {
								medium?: "Memory" | ""
								sizeLimit?: string
							}
							hostPath?: {
								path: string
								type?: "DirectoryOrCreate" | "Directory" | "FileOrCreate" | "File" | "Socket" | "CharDevice" | "BlockDevice"
							}
							secret?: {
								secretName: string
								items?: [...{
									key:  string
									path: string
									mode?: uint32
								}]
								defaultMode?: uint32
								optional?: bool
							}
							configMap?: {
								name: string
								items?: [...{
									key:  string
									path: string
									mode?: uint32
								}]
								defaultMode?: uint32
								optional?: bool
							}
							persistentVolumeClaim?: {
								claimName: string
								readOnly?: bool
							}
							projected?: {
								sources: [...{
									secret?: {
										name: string
										items?: [...{
											key:  string
											path: string
											mode?: uint32
										}]
										optional?: bool
									}
									configMap?: {
										name: string
										items?: [...{
											key:  string
											path: string
											mode?: uint32
										}]
										optional?: bool
									}
									downwardAPI?: {
										items?: [...{
											path: string
											fieldRef?: {
												fieldPath: string
												apiVersion?: string
											}
											resourceFieldRef?: {
												resource: string
												containerName?: string
												divisor?: string
											}
											mode?: uint32
										}]
									}
									serviceAccountToken?: {
										path: string
										expirationSeconds?: int64
										audience?: string
									}
								}]
								defaultMode?: uint32
							}
						}]
						
						restartPolicy?: "Always" | "OnFailure" | "Never" | *"Never"
						terminationGracePeriodSeconds?: int64
						activeDeadlineSeconds?: int64
						dnsPolicy?: "ClusterFirst" | "ClusterFirstWithHostNet" | "Default" | "None"
						nodeSelector?: [string]: string
						serviceAccountName?: string
						serviceAccount?: string
						automountServiceAccountToken?: bool
						nodeName?: string
						hostNetwork?: bool
						hostPID?: bool
						hostIPC?: bool
						shareProcessNamespace?: bool
						
						securityContext?: {
							runAsUser?: int64
							runAsGroup?: int64
							runAsNonRoot?: bool
							fsGroup?: int64
							fsGroupChangePolicy?: "OnRootMismatch" | "Always"
							supplementalGroups?: [...int64]
							seLinuxOptions?: {
								user?: string
								role?: string
								type?: string
								level?: string
							}
							windowsOptions?: {
								gmsaCredentialSpecName?: string
								gmsaCredentialSpec?: string
								runAsUserName?: string
								hostProcess?: bool
							}
							seccompProfile?: {
								type: "RuntimeDefault" | "Unconfined" | "Localhost"
								localhostProfile?: string
							}
						}
						
						imagePullSecrets?: [...{
							name: string
						}]
						
						hostname?: string
						subdomain?: string
						
						affinity?: {
							nodeAffinity?: #NodeAffinity
							podAffinity?: #PodAffinity
							podAntiAffinity?: #PodAntiAffinity
						}
						
						schedulerName?: string
						
						tolerations?: [...{
							key?: string
							operator?: "Exists" | "Equal"
							value?: string
							effect?: "NoSchedule" | "PreferNoSchedule" | "NoExecute"
							tolerationSeconds?: int64
						}]
						
						hostAliases?: [...{
							ip: string
							hostnames?: [...string]
						}]
						
						priorityClassName?: string
						priority?: int32
						
						dnsConfig?: {
							nameservers?: [...string]
							searches?: [...string]
							options?: [...{
								name: string
								value?: string
							}]
						}
						
						readinessGates?: [...{
							conditionType: string
						}]
						
						runtimeClassName?: string
						enableServiceLinks?: bool
						
						preemptionPolicy?: "PreemptLowerPriority" | "Never"
						
						overhead?: [string]: string
						
						topologySpreadConstraints?: [...{
							maxSkew: int32
							topologyKey: string
							whenUnsatisfiable: "DoNotSchedule" | "ScheduleAnyway"
							labelSelector?: {
								matchLabels?: [string]: string
								matchExpressions?: [...{
									key: string
									operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
									values?: [...string]
								}]
							}
						}]
						
						setHostnameAsFQDN?: bool
						
						os?: {
							name: "linux" | "windows"
						}
					}
				}
				
				// TTLSecondsAfterFinished limits the lifetime of a Job that has finished
				ttlSecondsAfterFinished?: int32
				
				// CompletionMode specifies how Pod completions are tracked
				completionMode?: "NonIndexed" | "Indexed"
				
				// Suspend specifies whether the Job controller should create Pods or not
				suspend?: bool
			}
		}
	}
}