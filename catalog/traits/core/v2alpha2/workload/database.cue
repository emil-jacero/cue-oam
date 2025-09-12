package workload

import (
	core "jacero.io/oam/core/v2alpha2"
	// schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
	data "jacero.io/oam/catalog/traits/core/v2alpha2/data"
)

// Database - Defines a database workload with type, version, and storage options
#DatabaseMeta: #Database.#metadata.#traits.Database

#Database: core.#Trait & {
	#metadata: #traits: Database: core.#TraitMetaComposite & {
		#kind:       "Database"
		description: "Managed database service with persistence support"
		domain:      "operational"
		scope: ["component"]
		composes: [
			#ContainerSetMeta,
			#ReplicaMeta,
			#RestartPolicyMeta,
			data.#VolumeMeta,
			data.#SecretMeta,
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
	replica: #Replica.replica & {count: 123}

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
