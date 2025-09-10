package v2alpha2

import (
	"strings"
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/v2alpha2/schema"
)

//////////////////////////////////////////////
//// Atomic Operational Traits
//////////////////////////////////////////////

// ContainerSet - Handles main containers and init containers
#ContainerSetTraitMeta: #ContainerSet.#metadata.#traits.ContainerSet

#ContainerSet: core.#Trait & {
	#metadata: #traits: ContainerSet: core.#TraitMetaAtomic & {
		#kind:       "ContainerSet"
		description: "Container specification with main and init containers support"
		domain:      "operational"
		scope: ["component"]
		provides: {containerSet: #ContainerSet.containerSet}
	}

	containerSet: {
		// Ensure at least one main container is defined
		containers: main: {name: string | *#metadata.name}
		// Main containers (at least one required)
		containers: [string]: schema.#ContainerSpec

		// Optional init containers that run before main containers
		init?: [string]: schema.#ContainerSpec
	}
}

// Replica - Controls the number of instances
#ReplicaTraitMeta: #Replica.#metadata.#traits.Replica

#Replica: core.#Trait & {
	#metadata: #traits: Replica: core.#TraitMetaAtomic & {
		#kind:       "Replica"
		description: "Specifies the number of replicas to run"
		domain:      "operational"
		scope: ["component"]
		// This trait modifies resources created by ContainerSet
		dependencies: [#ContainerSetTraitMeta]
		provides: {replica: #Replica.replica}
	}

	replica: {
		count: uint | *1
	}
}

// RestartPolicy - Controls restart behavior
#RestartPolicyTraitMeta: #RestartPolicy.#metadata.#traits.RestartPolicy

#RestartPolicy: core.#Trait & {
	#metadata: #traits: RestartPolicy: {
		#kind:       "RestartPolicy"
		description: "Defines restart behavior for containers"
		domain:      "operational"
		scope: ["component"]
		// This trait modifies Pod spec created by ContainerSet
		dependencies: [#ContainerSetTraitMeta]
		provides: {restartPolicy: #RestartPolicy.restartPolicy}
	}

	restartPolicy: string | *"Always" | "OnFailure" | "Never"
}

// UpdateStrategy - Controls how updates are applied
#UpdateStrategyTraitMeta: #UpdateStrategy.#metadata.#traits.UpdateStrategy

#UpdateStrategy: core.#Trait & {
	#metadata: #traits: UpdateStrategy: core.#TraitMetaAtomic & {
		#kind:       "UpdateStrategy"
		description: "Defines how updates are applied to running instances"
		domain:      "operational"
		scope: ["component"]
		// This trait modifies Deployment/StatefulSet created by ContainerSet
		dependencies: [#ContainerSetTraitMeta]
		provides: {updateStrategy: #UpdateStrategy.updateStrategy}
	}

	updateStrategy: {
		type: *"RollingUpdate" | "Recreate"

		// Only applicable when type is "RollingUpdate"
		if type == "RollingUpdate" {
			rollingUpdate?: {
				maxSurge?:       uint | *1
				maxUnavailable?: uint | *0
			}
		}
	}
}

//////////////////////////////////////////////
//// Legacy Composite Traits (for compatibility)
//////////////////////////////////////////////

// Workload trait definition (now composite, built from atomic traits)
// Provides a generic workload definition with support for containers, init containers, deployment strategies, and port exposure
#WorkloadTraitMeta: #Workload.#metadata.#traits.Workload

#Workload: core.#Trait & {
	#metadata: #traits: Workload: core.#TraitMetaComposite & {
		#kind:       "Workload"
		description: "Generic workload trait for defining containerized applications with deployment strategies and network exposure"
		domain:      "operational"
		scope: ["component"]
		composes: [
			#ContainerSetTraitMeta,
			#ReplicaTraitMeta,
			#RestartPolicyTraitMeta,
			#UpdateStrategyTraitMeta,
			#ExposeTraitMeta,
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
		expose: #Expose.expose

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

// Database trait definition (composite trait using atomic traits)
// Provides a managed database service (PostgreSQL or MySQL)
#DatabaseTraitMeta: #Database.#metadata.#traits.Database
#Database: core.#Trait & {
	#metadata: #traits: Database: core.#TraitMetaComposite & {
		#kind:       "Database"
		description: "Managed database service with persistence support"
		domain:      "operational"
		scope: ["component"]
		composes: [
			#ContainerSetTraitMeta,
			#ReplicaTraitMeta,
			#RestartPolicyTraitMeta,
			#VolumeTraitMeta,
			#SecretTraitMeta,
		]
		provides: {database: #Database.database}
	}

	database: {
		type!:    "postgres" | "mysql"
		version!: string
		persistence: {
			enabled: bool | *true
			size:    string | *"10Gi"
		}
		credentials: {
			username?: string | *"admin"
			password?: string | *"password"
		}
	}

	secrets: {
		if database.credentials.username != _|_ || database.credentials.password != _|_ {
			dbCredentials: {
				type: "Opaque"
				data: {
					if database.credentials.username != _|_ {
						username: database.credentials.username
					}
					if database.credentials.password != _|_ {
						password: database.credentials.password
					}
				}
			}
		}
	}

	// Configure replica count
	replica: #Replica.replica & {count: 1}

	// Configure restart policy
	restartPolicy: #RestartPolicy.restartPolicy & {"Always"}

	// Configure containers based on database type
	containerSet: #ContainerSet.containerSet & {
		containers: main: {
			if database.type == "postgres" {
				name: "postgres"
				image: {
					repository: "postgres"
					tag:        database.version
				}
				ports: [{
					name:       "postgres"
					protocol:   "TCP"
					targetPort: 5432
				}]
				env: [
					{name: "POSTGRES_DB", value: #metadata.name},
					{name: "POSTGRES_USER", value: "admin"},
					{name: "POSTGRES_PASSWORD", value: "password"},
				]
				if database.persistence.enabled {
					volumeMounts: [volumes.dbData]
				}
			}
			if database.type == "mysql" {
				name: "mysql"
				image: {
					repository: "mysql"
					tag:        database.version
				}
				ports: [{
					name:       "mysql"
					protocol:   "TCP"
					targetPort: 3306
				}]
				env: [
					{name: "MYSQL_DATABASE", value: #metadata.name},
					{name: "MYSQL_USER", value: "admin"},
					{name: "MYSQL_PASSWORD", value: "password"},
				]
				if database.persistence.enabled {
					volumeMounts: [volumes.dbData]
				}
			}
		}
	}
	// Volume configuration
	volumes: {
		if database.persistence.enabled {
			dbData: {
				type:      "volume"
				name:      "db-data"
				size:      database.persistence.size
				mountPath: string | *"/var/lib/data"
			}
		}
	}
}
