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
		web: #Component & {
			#Workload
			replicas: 3
			containers: main: {
				name:     "nginx"
				image:    "nginx:latest"
				volumeMounts: [volumes.vol1 & {mountPath: "/usr/share/nginx/html"}]
			}
			#Volume
			volumes: vol1: {
				type: "volume"
				name: "frontend-storage"
				size: "1Gi"
			}
		}
		db: #Component & {
			#Database
			database: {
				databaseType: "postgres"
				version:      "15"
				volumeMount: volumes.vol1 & {mountPath: "/var/lib/postgresql/data"}
				postgres: {
					configFrom: config.db
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

//////////////////////////////////////////////
// Example Usage
//////////////////////////////////////////////

// Import the application definition
// (assuming myApp is defined as in your main.cue)

// Generate Kubernetes manifests
k8sManifests: #ApplicationRenderer & {
	app: myApp
}

// The output will be in k8sManifests.output
// This generates a Kubernetes List with all resources

// Generate Docker Compose configuration
composeConfig: #ComposeApplicationRenderer & {
	app: myApp
}

// The output will be in composeConfig.output
// This generates a Docker Compose YAML structure
