package examples

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	k8sprovider "jacero.io/oam/providers/kubernetes"
)

// To illustrate how an application can be defined.
myApp: core.#Application & {
	#metadata: {
		name:      "my-web-app"
		namespace: "default"
		version:   "2.1.0"
		// Application-level metadata applied to ALL resources
		labels: {
			"team":        "platform"
			"environment": "prod"
			"cost-center": "engineering"
		}
		annotations: {
			"app.company.com/owner": "platform-team"
		}
	}

	scopes: {
		frontend: {
			trait.#SharedNetwork
			appliesTo: [components.web, components.api]
			sharedNetwork: {}
		}
		backend: {
			trait.#SharedNetwork
			appliesTo: [components.api, components.db]
			sharedNetwork: {}
		}
	}

	components: {
		// Frontend component with its own metadata
		web: {
			#metadata: {
				// Component-specific metadata
				labels: {
					"tier":    "frontend"
					"exposed": "true"
				}
				annotations: {
					"monitoring.coreos.com/scrape":               "true"
					"nginx.ingress.kubernetes.io/rewrite-target": "/"
				}
			}

			// Add trait compositions
			trait.#ContainerSet
			trait.#Expose

			// Frontend workload
			containerSet: {
				containers: {
					web: {
						name: "nginx-frontend"
						image: {
							repository: "nginx"
							tag:        "1.21"
						}
						ports: [{
							name:       "http"
							targetPort: 80
							protocol:   "TCP"
						}]
					}
				}
			}

			// Expose the frontend
			expose: {
				type: "ClusterIP"
				ports: [{
					name:        "http"
					targetPort:  80
					exposedPort: 80
				}]
			}
		}

		// Backend API component
		api: {
			#metadata: {
				labels: {
					"tier":            "backend"
					"database-access": "true"
				}
				annotations: {
					"app.company.com/database": "postgres-main"
				}
			}

			// Add trait compositions
			trait.#ContainerSet
			trait.#Expose

			containerSet: {
				containers: {
					api: {
						name: "nodejs-api"
						image: {
							repository: "node"
							tag:        "16-alpine"
						}
						ports: [{
							name:       "api"
							targetPort: 3000
							protocol:   "TCP"
						}]
						env: [{
							name:  "NODE_ENV"
							value: "production"
						}, {
							name:  "DB_HOST"
							value: "db"
						}, {
							name:  "DB_PORT"
							value: "5432"
						}, {
							name:  "DB_NAME"
							value: "my-web-app"
						}]
					}
				}
			}

			expose: {
				type: "ClusterIP"
				ports: [{
					name:        "api"
					targetPort:  3000
					exposedPort: 3000
				}]
			}
		}

		// PostgreSQL database component
		db: {
			#metadata: {
				labels: {
					"tier":          "database"
					"database-type": "postgres"
				}
				annotations: {
					"app.company.com/persistent": "true"
				}
			}

			// Add basic container and volume traits
			trait.#Database

			database: {
				type:    "postgres"
				version: "15"
				persistence: {
					enabled: true
					size:    "20Gi"
				}
			}
		}
	}
}

// Generate Kubernetes manifests using our provider
k8sManifests: k8sprovider.#ProviderKubernetes.render & {
	app: myApp
}
