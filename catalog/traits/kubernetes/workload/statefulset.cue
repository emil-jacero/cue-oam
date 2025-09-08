package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

#StatefulSet: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "StatefulSet"
	
	description: "Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage"
	
	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/apps/v1.StatefulSet",
	]
	
	provides: {
		statefulset: {
			// StatefulSet metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// StatefulSet specification
			spec: {
				// Number of desired pods
				replicas: uint32 | *1
				
				// ServiceName is the name of the service that governs this StatefulSet
				serviceName: string
				
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
				
				// VolumeClaimTemplates is a list of claims that pods are allowed to reference
				volumeClaimTemplates?: [...{
					metadata: {
						name: string
						labels?: [string]: string
						annotations?: [string]: string
					}
					spec: {
						accessModes?: [...("ReadWriteOnce" | "ReadOnlyMany" | "ReadWriteMany" | "ReadWriteOncePod")]
						selector?: {
							matchLabels?: [string]: string
							matchExpressions?: [...{
								key: string
								operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
								values?: [...string]
							}]
						}
						resources?: {
							limits?: {
								storage?: string
								[string]: string
							}
							requests?: {
								storage?: string
								[string]: string
							}
						}
						volumeName?: string
						storageClassName?: string
						volumeMode?: "Filesystem" | "Block"
						dataSource?: {
							name: string
							kind: string
							apiGroup?: string
						}
						dataSourceRef?: {
							name: string
							kind: string
							apiGroup?: string
							namespace?: string
						}
					}
				}]
				
				// Update strategy
				updateStrategy?: {
					type?: "RollingUpdate" | "OnDelete"
					rollingUpdate?: {
						partition?: int32
						maxUnavailable?: uint32 | string
					}
				}
				
				// PodManagementPolicy controls how pods are created during initial scale up
				podManagementPolicy?: "OrderedReady" | "Parallel"
				
				// revisionHistoryLimit is the maximum number of revisions to maintain
				revisionHistoryLimit?: int32
				
				// Minimum number of seconds for which a newly created pod should be ready
				minReadySeconds?: int32
				
				// persistentVolumeClaimRetentionPolicy describes the policy for PVCs
				persistentVolumeClaimRetentionPolicy?: {
					whenDeleted?: "Retain" | "Delete"
					whenScaled?: "Retain" | "Delete"
				}
				
				// The ordinals controls pod creation and deletion
				ordinals?: {
					start?: int32
				}
			}
		}
	}
}