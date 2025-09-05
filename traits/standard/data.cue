package standard

import (
	corev2 "jacero.io/oam/core/v2alpha1"
)

#Database: corev2.#Trait & {
	#metadata: #traits: Database: {
		provides: {database: #Database.database}
		requires: [
			"core.oam.dev/v2alpha1.DatabasePostgreSQL",
			"core.oam.dev/v2alpha1.DatabaseMySQL",
			"core.oam.dev/v2alpha1.DatabaseMongoDB",
			"core.oam.dev/v2alpha1.DatabaseRedis",
		]
		extends: [#Workload.#metadata.#traits.Workload]
		description: "Describes a database service that runs one or more containers. By default, the database runs a single container called 'main'."
	}

	database: {
		engine:   *"mysql" | "postgresql" | "mongodb" | "redis" | string
		version?: string
		volume:   #Volume
		workload: #Workload.workload & {
			containers: [string]: #ContainerSpec & {
				name: string | *"main"
				env?: [{
					name:  string
					value: string
				}]
				ports?: [{
					name:          string
					containerPort: int
					protocol?:     *"TCP" | "UDP"
				}]
				resources?: {
					requests?: {
						cpu?:    string
						memory?: string
					}
					limits?: {
						cpu?:    string
						memory?: string
					}
				}
				volumeMounts?: [{
					name:      string
					mountPath: string
					subPath?:  string
					readOnly?: bool | *false
				}]
			}
			replicas?:      uint | *1
			deploymentType: string | *"StatefulSet"
			volumes?: [{
				name: string
				persistentVolumeClaim?: {
					claimName: string
				}
			}]
		}
	}
}
