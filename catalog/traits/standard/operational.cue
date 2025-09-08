package standard

import (
	"strings"
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/standard/schema"
)

#WorkloadTrait: core.#TraitObject & {
	#kind:    "Workload"
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	requiredCapabilities: [
		"core.oam.dev/v2alpha1.Workload",
	]
	provides: {workload: #Workload.workload}
}
#Workload: core.#Trait & {
	#metadata: #traits: Workload: #WorkloadTrait

	workload: {
		containers: [string]: schema.#ContainerSpec
		containers: main: {name: string | *#metadata.name}

		// Optional init containers that run before the main containers
		initContainers?: [string]: schema.#ContainerSpec

		// Restart policy for all containers
		// Can be overridden per container
		// Defaults to "Always"
		restart: *"Always" | "OnFailure" | "Never"

		// Deployment type for the workload
		// In Kubernetes this maps to Deployment, StatefulSet or DaemonSet
		// For Docker Compose Deployment is mapped to service, DaemonSet and StatefulSet are not supported
		deploymentType?: *"Deployment" | "StatefulSet" | "DaemonSet"
		if deploymentType != _|_ {
			if deploymentType == "Deployment" {
				replicas?: uint | *1
				strategy?: *"Recreate" | "RollingUpdate"
				rollingUpdate?: {
					maxSurge?:       uint | *1
					maxUnavailable?: uint | *0
				}
			}
			if deploymentType == "StatefulSet" {
				replicas?:            uint | *1
				serviceName!:         string & strings.MaxRunes(253)
				podManagementPolicy?: *"OrderedReady" | "Parallel"
				updateStrategy?:      *"OnDelete" | "RollingUpdate"
				rollingUpdate?: {
					partition?: uint | *0
				}
			}
			if deploymentType == "DaemonSet" {
				updateStrategy?: *"OnDelete" | "RollingUpdate"
				rollingUpdate?: {
					maxUnavailable?: uint | *1
				}
			}
		}
	}
}

// Database trait definition
// Provides a managed database service (PostgreSQL or MySQL)
#Database: core.#Trait & {
	#metadata: #traits: Database: #DatabaseTrait
	database: {
		type!:     "postgres" | "mysql"
		replicas?: uint | *1
		version!:  string
		persistence: {
			enabled: bool | *true
			size:    string | *"10Gi"
		}
	}

	volumes: {
		if database.persistence.enabled {
			dbData: {
				scope:     "volume"
				name:      "db-data"
				size:      database.persistence.size
				mountPath: string | *"/var/lib/data"
			}
		}
		if database.persistence.enabled {
			dbData: {
				scope:     "volume"
				name:      "db-data"
				size:      database.persistence.size
				mountPath: string | *"/var/lib/data"
			}
		}
	}
	workload: #Workload.workload & {
		if database.type == "postgres" {
			containers: main: {
				name: "postgres"
				image: {
					registry: "docker.io/library/postgres"
					tag:      database.version
				}
				ports: [{
					name:          "postgres"
					protocol:      "TCP"
					containerPort: 5432
				}]
				if database.persistence.enabled {
					volumeMounts: [volumes.dbData & {mountPath: "/var/lib/postgresql/data"}]
				}
				env: "POSTGRES_DB": {name: "POSTGRES_DB", value: #metadata.name}
				env: "POSTGRES_USER": {name: "POSTGRES_USER", value: "admin"}
				env: "POSTGRES_PASSWORD": {name: "POSTGRES_PASSWORD", value: "password"}
			}
		}
		if database.type == "mysql" {
			containers: main: {
				name: "mysql"
				image: {
					registry: "docker.io/library/mysql"
					tag:      database.version
				}
				ports: [{
					name:          "mysql"
					protocol:      "TCP"
					containerPort: 3306
				}]
				if database.persistence.enabled {
					volumeMounts: [volumes.dbData & {mountPath: "/var/lib/mysql"}]
				}
				env: "MYSQL_DATABASE": {name: "MYSQL_DATABASE", value: #metadata.name}
				env: "MYSQL_USER": {name: "MYSQL_USER", value: "admin"}
				env: "MYSQL_PASSWORD": {name: "MYSQL_PASSWORD", value: "password"}
			}
		}
	}
}
#DatabaseTrait: core.#TraitObject & {
	#kind:    "Database"
	category: "operational"
	scope: ["component"]
	composes: [#WorkloadTrait, #VolumeTrait]

	provides: {database: #Database.database}
}
