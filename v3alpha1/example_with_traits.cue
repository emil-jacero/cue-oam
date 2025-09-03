package v3alpha1

import (
	"jacero.io/oam/v3alpha1/core"
	"jacero.io/oam/v3alpha1/transformer"
)

// Define a custom ingress trait
#IngressTrait: core.#Trait & {
	hostname: string
	path:     string | *"/"
	port:     int

	// This trait could generate an Ingress resource
	// but needs component context to fully render
}

// Define a component type that uses multiple traits
#WebService: {
	core.#Workload

	// Configure the workload
	containers: main: {
		image: "nginx:latest"
		env: {
			PORT: "8080"
		}
		resources: {
			requests: {
				cpu:    "100m"
				memory: "128Mi"
			}
			limits: {
				cpu:    "500m"
				memory: "512Mi"
			}
		}
	}

	#IngressTrait

	// Configure the ingress trait
	hostname: "example.com"
	path:     "/api"
	port:     8080
}

// Example module using components with traits
exampleModule: core.#Module & {
	#metadata: {
		name:      "web-app"
		namespace: "production"
	}

	components: {
		api: core.#Component & {
			#WebService
			#metadata: #id: "api"

			// This component instance generates its Kubernetes resources
			#kubernetesOutput: [
				// Deployment from workload trait
				{
					apiVersion: "apps/v1"
					kind:       "Deployment"
					metadata: {
						name:      "api"
						namespace: "production"
						labels: {
							"oam.dev/component":   "api"
							"oam.dev/application": "web-app"
							"oam.dev/traits":      "workload,ingress"
						}
					}
					spec: {
						replicas: 3
						selector: matchLabels: app: "api"
						template: {
							metadata: labels: app: "api"
							spec: containers: [{
								name:  "main"
								image: "nginx:latest"
								env: [
									{name: "PORT", value: "8080"},
								]
								resources: {
									requests: {
										cpu:    "100m"
										memory: "128Mi"
									}
									limits: {
										cpu:    "500m"
										memory: "512Mi"
									}
								}
							}]
						}
					}
				},
				// Service to expose the deployment
				{
					apiVersion: "v1"
					kind:       "Service"
					metadata: {
						name:      "api"
						namespace: "production"
						labels: {
							"oam.dev/component":   "api"
							"oam.dev/application": "web-app"
						}
					}
					spec: {
						selector: app: "api"
						ports: [{
							port:       8080
							targetPort: 8080
						}]
					}
				},
				// Ingress from ingress trait
				{
					apiVersion: "networking.k8s.io/v1"
					kind:       "Ingress"
					metadata: {
						name:      "api"
						namespace: "production"
						labels: {
							"oam.dev/component":   "api"
							"oam.dev/application": "web-app"
							"oam.dev/trait":       "ingress"
						}
					}
					spec: {
						rules: [{
							host: "example.com"
							http: {
								paths: [{
									path:     "/api"
									pathType: "Prefix"
									backend: {
										service: {
											name: "api"
											port: number: 8080
										}
									}
								}]
							}
						}]
					}
				},
			]
		}

		database: core.#Component & {
			core.#Volume
			#metadata: #id: "database"

			volumes: main: {
				type: "volume"
				size: "10Gi"
			}

			// Volume component generates its Kubernetes resources
			#kubernetesOutput: [
				{
					apiVersion: "v1"
					kind:       "PersistentVolumeClaim"
					metadata: {
						name:      "database-storage"
						namespace: "production"
						labels: {
							"oam.dev/component":   "database"
							"oam.dev/application": "web-app"
							"oam.dev/trait":       "volume"
						}
					}
					spec: {
						accessModes: ["ReadWriteOnce"]
						resources: {
							requests: {
								storage: volumes.main.size
							}
						}
					}
				},
			]
		}
	}
}

// Transform the module to Kubernetes resources
kubernetesOutput: transformer.#EnhancedKubernetesTransformer & {
	#module: exampleModule
}
