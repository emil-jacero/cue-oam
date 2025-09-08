package standard

import (
	"strings"
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/schema"
)

//////////////////////////////////////////////
//// Atomic Operational Traits
//////////////////////////////////////////////

// ContainerSet - Handles main containers and init containers
#ContainerSetTraitMeta: core.#TraitMeta & {
	#kind:    "ContainerSet"
	description: "Container specification with main and init containers support"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.ContainerSet",
	]
	provides: {
		containerSet: {
			// Main containers (at least one required)
			containers: [string]: schema.#ContainerSpec
			
			// Optional init containers that run before main containers
			init?: [string]: schema.#ContainerSpec
		}
	}
}
#ContainerSet: core.#Trait & {
	#metadata: #traits: ContainerSet: #ContainerSetTraitMeta

	containerSet: #ContainerSetTraitMeta.provides.containerSet & {
		// Ensure at least one main container is defined
		containers: main: {name: string | *#metadata.name}
	}
}

// Replica - Controls the number of instances
#ReplicaTraitMeta: core.#TraitMeta & {
	#kind:    "Replica"
	description: "Specifies the number of replicas to run"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Replica",
	]
	// This trait modifies resources created by ContainerSet
	requires: [#ContainerSetTraitMeta]
	provides: {
		replica: {
			count: uint | *1
		}
	}
}
#Replica: core.#Trait & {
	#metadata: #traits: Replica: #ReplicaTraitMeta

	replica: #ReplicaTraitMeta.provides.replica
}

// RestartPolicy - Controls restart behavior
#RestartPolicyTraitMeta: core.#TraitMeta & {
	#kind:    "RestartPolicy"
	description: "Defines restart behavior for containers"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.RestartPolicy",
	]
	// This trait modifies Pod spec created by ContainerSet
	requires: [#ContainerSetTraitMeta]
	provides: {
		restartPolicy: string | *"Always" | "OnFailure" | "Never"
	}
}
#RestartPolicy: core.#Trait & {
	#metadata: #traits: RestartPolicy: #RestartPolicyTraitMeta

	restartPolicy: #RestartPolicyTraitMeta.provides.restartPolicy
}

// UpdateStrategy - Controls how updates are applied
#UpdateStrategyTraitMeta: core.#TraitMeta & {
	#kind:    "UpdateStrategy"
	description: "Defines how updates are applied to running instances"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.UpdateStrategy",
	]
	// This trait modifies Deployment/StatefulSet created by ContainerSet
	requires: [#ContainerSetTraitMeta]
	provides: {
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
}
#UpdateStrategy: core.#Trait & {
	#metadata: #traits: UpdateStrategy: #UpdateStrategyTraitMeta

	updateStrategy: #UpdateStrategyTraitMeta.provides.updateStrategy
}

// Labels - Adds custom labels to the workload
#LabelsTraitMeta: core.#TraitMeta & {
	#kind:    "Labels"
	description: "Adds custom labels to the workload"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Labels",
	]
	// This trait modifies resources created by ContainerSet
	requires: [#ContainerSetTraitMeta]
	provides: {
		labels: [string]: string
	}
}
#Labels: core.#Trait & {
	#metadata: #traits: Labels: #LabelsTraitMeta
	labels: #LabelsTraitMeta.provides.labels
}

// Annotations - Adds custom annotations to the workload
#AnnotationsTraitMeta: core.#TraitMeta & {
	#kind:    "Annotations"
	description: "Adds custom annotations to the workload"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Annotations",
	]
	// This trait modifies resources created by ContainerSet
	requires: [#ContainerSetTraitMeta]
	provides: {
		annotations: [string]: string
	}
}
#Annotations: core.#Trait & {
	#metadata: #traits: Annotations: #AnnotationsTraitMeta
	annotations: #AnnotationsTraitMeta.provides.annotations
}

//////////////////////////////////////////////
//// Legacy Composite Traits (for compatibility)
//////////////////////////////////////////////

// Workload trait definition (now composite, built from atomic traits)
// Provides a generic workload definition with support for containers, init containers, deployment strategies, and port exposure
#WorkloadTraitMeta: core.#TraitMeta & {
	#kind:    "Workload"
	description: "Generic workload trait for defining containerized applications with deployment strategies and network exposure"
	type:     "composite"
	category: "operational"
	scope: ["component"]
	composes: [
		#ContainerSetTraitMeta,
		#ReplicaTraitMeta,
		#RestartPolicyTraitMeta,
		#UpdateStrategyTraitMeta,
		#ExposeTraitMeta,
	]
	provides: {
		workload: {
			// Legacy interface for backward compatibility
			container: #ContainerSet.containerSet.containers
			initContainers?: #ContainerSet.containerSet.init
			restart: #RestartPolicy.restartPolicy
			replicas?: #Replica.replica.count
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
					replicas?: replicas.count
					serviceName!: string & strings.MaxRunes(253)
					podManagementPolicy?: *"OrderedReady" | "Parallel"
					updateStrategy?: *"OnDelete" | "RollingUpdate"
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
}
#Workload: core.#Trait & {
	#metadata: #traits: Workload: #WorkloadTraitMeta

	workload: #WorkloadTraitMeta.provides.workload
}

// Database trait definition (composite trait using atomic traits)
// Provides a managed database service (PostgreSQL or MySQL)
#DatabaseTraitMeta: core.#TraitMeta & {
	#kind:    "Database"
	description: "Managed database service with persistence support"
	type:     "composite"
	category: "operational"
	scope: ["component"]
	composes: [
		#ContainerSetTraitMeta,
		#ReplicaTraitMeta,
		#RestartPolicyTraitMeta,
		#VolumeTraitMeta,
	]
	provides: {database: #Database.database}
}
#Database: core.#Trait & {
	#metadata: #traits: Database: #DatabaseTraitMeta

	database: {
		type!:     "postgres" | "mysql"
		version!:  string
		persistence: {
			enabled: bool | *true
			size:    string | *"10Gi"
		}
	}

	// Configure replica count
	replica: #Replica.replica & {count: 1}

	// Configure restart policy
	restartPolicy: #RestartPolicy.restartPolicy & {"Always"}

	// Configure containers based on database type
	containers: #ContainerSet.containers & {
		if database.type == "postgres" {
			main: main: {
				name: "postgres"
				image: {
					repository: "postgres"
					tag:        database.version
				}
				ports: [{
					name:          "postgres"
					protocol:      "TCP"
					containerPort: 5432
				}]
				env: [
					{name: "POSTGRES_DB", value: #metadata.name},
					{name: "POSTGRES_USER", value: "admin"},
					{name: "POSTGRES_PASSWORD", value: "password"},
				]
				if database.persistence.enabled {
					volumeMounts: [{
						name:      "db-data"
						mountPath: "/var/lib/postgresql/data"
					}]
				}
			}
		}
		if database.type == "mysql" {
			main: main: {
				name: "mysql"
				image: {
					repository: "mysql"
					tag:        database.version
				}
				ports: [{
					name:          "mysql"
					protocol:      "TCP"
					containerPort: 3306
				}]
				env: [
					{name: "MYSQL_DATABASE", value: #metadata.name},
					{name: "MYSQL_USER", value: "admin"},
					{name: "MYSQL_PASSWORD", value: "password"},
				]
				if database.persistence.enabled {
					volumeMounts: [{
						name:      "db-data"
						mountPath: "/var/lib/mysql"
					}]
				}
			}
		}
	}

	// Volume configuration
	volumes: {
		if database.persistence.enabled {
			dbData: {
				scope:     "volume"
				name:      "db-data"
				size:      database.persistence.size
				mountPath: string | *"/var/lib/data"
			}
		}
	}
}
