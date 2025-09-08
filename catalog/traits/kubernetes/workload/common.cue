package workload

// Common definitions used across workload traits

// Probe configuration for health checks
#Probe: {
	httpGet?: {
		path?: string
		port: uint & >=1 & <=65535 | string
		host?: string
		scheme?: "HTTP" | "HTTPS"
		httpHeaders?: [...{
			name: string
			value: string
		}]
	}
	tcpSocket?: {
		port: uint & >=1 & <=65535 | string
		host?: string
	}
	exec?: {
		command?: [...string]
	}
	grpc?: {
		port: int32
		service?: string
	}
	initialDelaySeconds?: int32
	periodSeconds?: int32
	timeoutSeconds?: int32
	successThreshold?: int32
	failureThreshold?: int32
	terminationGracePeriodSeconds?: int64
}

// Lifecycle handlers for containers
#Handler: {
	exec?: {
		command?: [...string]
	}
	httpGet?: {
		path?: string
		port: uint & >=1 & <=65535 | string
		host?: string
		scheme?: "HTTP" | "HTTPS"
		httpHeaders?: [...{
			name: string
			value: string
		}]
	}
	tcpSocket?: {
		port: uint & >=1 & <=65535 | string
		host?: string
	}
}

// Security context for containers
#SecurityContext: {
	capabilities?: {
		add?: [...string]
		drop?: [...string]
	}
	privileged?: bool
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
	runAsUser?: int64
	runAsGroup?: int64
	runAsNonRoot?: bool
	readOnlyRootFilesystem?: bool
	allowPrivilegeEscalation?: bool
	procMount?: "Default" | "Unmasked"
	seccompProfile?: {
		type: "RuntimeDefault" | "Unconfined" | "Localhost"
		localhostProfile?: string
	}
}

// Node affinity rules
#NodeAffinity: {
	requiredDuringSchedulingIgnoredDuringExecution?: {
		nodeSelectorTerms: [...{
			matchExpressions?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
				values?: [...string]
			}]
			matchFields?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
				values?: [...string]
			}]
		}]
	}
	preferredDuringSchedulingIgnoredDuringExecution?: [...{
		weight: int32
		preference: {
			matchExpressions?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
				values?: [...string]
			}]
			matchFields?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist" | "Gt" | "Lt"
				values?: [...string]
			}]
		}
	}]
}

// Pod affinity rules
#PodAffinity: {
	requiredDuringSchedulingIgnoredDuringExecution?: [...{
		labelSelector?: {
			matchLabels?: [string]: string
			matchExpressions?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
				values?: [...string]
			}]
		}
		namespaces?: [...string]
		topologyKey: string
		namespaceSelector?: {
			matchLabels?: [string]: string
			matchExpressions?: [...{
				key: string
				operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
				values?: [...string]
			}]
		}
	}]
	preferredDuringSchedulingIgnoredDuringExecution?: [...{
		weight: int32
		podAffinityTerm: {
			labelSelector?: {
				matchLabels?: [string]: string
				matchExpressions?: [...{
					key: string
					operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
					values?: [...string]
				}]
			}
			namespaces?: [...string]
			topologyKey: string
			namespaceSelector?: {
				matchLabels?: [string]: string
				matchExpressions?: [...{
					key: string
					operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
					values?: [...string]
				}]
			}
		}
	}]
}

// Pod anti-affinity rules (same structure as PodAffinity)
#PodAntiAffinity: #PodAffinity