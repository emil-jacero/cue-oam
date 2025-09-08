package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

#DaemonSet: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "DaemonSet"
	
	description: "Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod"
	
	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/apps/v1.DaemonSet",
	]
	
	provides: {
		daemonset: {
			// DaemonSet metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// DaemonSet specification
			spec: {
				// Label selector for pods
				selector: {
					matchLabels: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}
				
				// Template for pod creation (same as Deployment)
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
						
						restartPolicy?: "Always" | "OnFailure" | "Never"
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
				
				// Update strategy
				updateStrategy?: {
					type?: "RollingUpdate" | "OnDelete"
					rollingUpdate?: {
						maxUnavailable?: uint32 | string
						maxSurge?: uint32 | string
					}
				}
				
				// Minimum number of seconds for which a newly created pod should be ready
				minReadySeconds?: int32
				
				// Number of old history to retain to allow rollback
				revisionHistoryLimit?: int32
			}
		}
	}
}