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
		domain:      "workload"
		scope: ["component"]
		composes: [
			#ContainerSetMeta,
			#ReplicasMeta,
			#RestartPolicyMeta,
			data.#VolumeMeta,
			data.#SecretMeta,
		]
		provides: database: #Database.database
	}

	D=database: {
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

	secrets: data.#Secret.secrets & {
		if D.credentials.username != _|_ || D.credentials.password != _|_ {
			dbCredentials: {
				type: "Opaque"
				data: {
					if D.credentials.username != _|_ {
						username: D.credentials.username
					}
					if D.credentials.password != _|_ {
						password: D.credentials.password
					}
				}
			}
		}
	}

	// Configure replica count
	replicas: #Replicas.replicas | *1

	// Configure restart policy
	restartPolicy: #RestartPolicy.restartPolicy & "Always"

	// Configure containers based on database type
	containerSet: #ContainerSet.containerSet & {
		containers: main: {
			if D.type == "postgres" {
				name: "postgres"
				image: {
					repository: "postgres"
					tag:        D.version
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
				if D.persistence.enabled {
					volumeMounts: [volumes.dbData]
				}
			}
			if D.type == "mysql" {
				name: "mysql"
				image: {
					repository: "mysql"
					tag:        D.version
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
				if D.persistence.enabled {
					volumeMounts: [volumes.dbData]
				}
			}
		}
	}
	// Volume configuration
	volumes: data.#Volume.volumes & {
		if D.persistence.enabled {
			dbData: {
				name:      "db-data"
				type:      "volume"
				size:      D.persistence.size
				mountPath: string | *"/var/lib/data"
			}
		}
	}
}
