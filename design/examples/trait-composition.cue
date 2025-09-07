package examples

//////////////////////////////////////////////////////////////////////
// Base traits
#Workload: #Trait & {
	#metadata: #traits: Workload: {
		category: "operational"
		provides: workload: #Workload.workload
		requires: [
			"core.oam.dev/v2alpha1.Workload",
		]
		traitScope: ["component"]
	}

	workload: {
		containers: [string]: {...}
		containers: main: {name: string | *#metadata.name}
	}
}
#Volume: #Trait & {
	#metadata: #traits: Volume: {
		category: "resource"
		provides: volumes: #Volume.volumes
		requires: [
			"core.oam.dev/v2alpha1.Volume",
		]
		traitScope: ["component"]
	}

	// Volumes to be created
	volumes: [string]: {
		name!:      string
		type!:      "emptyDir" | "volume"
		mountPath!: string
		if type == "volume" {
			size?: string
		}
	}
	// Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
	for k, v in volumes {
		volumes: (k): v & {
			name: string | *k
		}
	}
}

//////////////////////////////////////////////////////////////////////
// Extended trait
#Database: #Trait & {
	#metadata: #traits: Database: {
		category: "operational"
		composes: [#Workload.#metadata.#traits.Workload, #Volume.#metadata.#traits.Volume]
		provides: database: #Database.database
		traitScope: ["component"]
		// requires: automatically computed from composed traits
	}

	database: {
		type:      "postgres" | "mysql"
		replicas?: uint | *1
		version:   string
		persistence: {
			enabled: bool | *true
			size:    string | *"10Gi"
		}
	}

	volumes: {if database.persistence.enabled {
		dbData: {
			type:      "volume"
			name:      "db-data"
			size:      database.persistence.size
			mountPath: string | *"/var/lib/data"
		}
	}}
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

	// Inherited fields. Useful for validation or defaults.
	for t in #metadata.#traits.Database.composes {
		t.provides
	}
}

testComposition: #Database & {
	#metadata: name: "my-database"
	database: {
		type:    "postgres"
		version: "15"
	}
}
