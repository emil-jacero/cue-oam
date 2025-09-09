package examples

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/standard"
)

core.#Application

// To illustrate how we can flatten the application structure when writing in a single file. Treat the whole file as one application definition.
// This could be useful to simplify writing applications for users.
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

components: {
	// Frontend component with its own metadata
	"web-frontend": {
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
	"api-backend": {
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
}
