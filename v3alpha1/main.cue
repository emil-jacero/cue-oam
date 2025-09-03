package v3alpha1

//////////////////////////////////////////////
//// Applications
//////////////////////////////////////////////
myApp: #Application & {
	#metadata: {
		name:    "my-app"
		version: "1.0.0"
	}
	scopes: {
		SharedNetwork1: #SharedNetwork & {
			children: [components.web, components.db]
		}
	}
	components: {
		web: {
			#Workload
			containers: main: {
				name:     "nginx"
				image:    "nginx:latest"
				replicas: 3
				volumes: [web.volumes.vol1 & {mountPath: "/usr/share/nginx/html"}]
			}
			#Volume
			volumes: vol1: {
				type: "volume"
				name: "frontend-storage"
				size: "1Gi"
			}
		}
		db: {
			#Database
			database: {
				databaseType: "postgres"
				version:      "15"
				volume: db.volumes.vol1 & {mountPath: "/var/lib/postgresql/data"}
				postgres: {
					configFrom: db.config.db
				}
			}
			#Volume
			volumes: vol1: {
				type: "volume"
				name: "database-storage"
				size: "5Gi"
			}
			#Config
			config: db: {
				data: {
					"POSTGRES_USER": "user"
					"POSTGRES_DB":   "mydb"
				}
			}
		}
	}
}
