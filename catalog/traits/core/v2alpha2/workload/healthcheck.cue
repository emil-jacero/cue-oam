package workload

import (
	core "jacero.io/oam/core/v2alpha2"
)

// HealthCheck - Configures liveness and readiness probes
#HealthCheckMeta: #HealthCheck.#metadata.#traits.HealthCheck
#HealthCheck: core.#Trait & {
	#metadata: #traits: HealthCheck: core.#TraitMetaAtomic & {
		#kind:       "HealthCheck"
		description: "Configures liveness and readiness probes for containers"
		domain:      "workload"
		scope: ["component"]
		schema: healthCheck: #HealthCheckSchema
	}

	healthCheck: #HealthCheckSchema
}

#HealthCheckSchema: {
	livenessProbe?:  #Probe
	readinessProbe?: #Probe
	startupProbe?:   #Probe
}

#Probe: {
	initialDelaySeconds?: int | *0
	periodSeconds?:       int | *10
	timeoutSeconds?:      int | *1
	successThreshold?:    int | *1
	failureThreshold?:    int | *3

	// One of the following handlers must be specified
	#Handler: #ExecHandler | #HTTPGetHandler | #TCPSocketHandler
	#ExecHandler: {
		exec: {
			command: [...string]
		}
	}
	#HTTPGetHandler: {
		httpGet: {
			path:    string
			port:    int
			host?:   string
			scheme?: "HTTP" | "HTTPS"
			httpHeaders?: [...{
				name:  string
				value: string
			}]
		}
	}
	#TCPSocketHandler: {
		tcpSocket: {
			port:  int
			host?: string
		}
	}
}
