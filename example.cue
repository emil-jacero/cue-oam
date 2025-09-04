package example

import (
	corev3 "jacero.io/oam/core/v3alpha1"
	traits "jacero.io/oam/traits/standard"
	k8sprovider "jacero.io/oam/providers/kubernetes"
)

// Example Application with Workload trait
webApp: corev3.#Application & {
	#metadata: {
		name:      "web-app"
		namespace: "demo"
		version:   "1.2.0"
		labels: {
			"environment": "demo"
		}
	}

	components: {
		frontend: {
			// Workload trait
			traits.#Workload
			workload: {
				replicas: 3
				containers: {
					main: {
						name: "nginx"
						image: {
							repository: "nginx"
							tag:        "1.24"
						}
						ports: [{
							name:          "http"
							containerPort: 80
							protocol:      "TCP"
						}]
						env: [{
							name:  "ENV"
							value: "production"
						}]
						resources: {
							requests: {cpu: "100m", memory: "128Mi"}
							limits: {cpu: "500m", memory: "512Mi"}
						}
						readinessProbe: {
							httpGet: {
								path: "/"
								port: 80
							}
							initialDelaySeconds: 5
							periodSeconds:       10
						}
					}
				}
			}
		}
		api: {
			// Workload trait
			traits.#Workload
			workload: {
				replicas: 2
				containers: {
					main: {
						name: "api-server"
						image: {
							repository: "node"
							tag:        "18-alpine"
						}
						ports: [
							{
								name:          "api"
								containerPort: 3000
								protocol:      "TCP"
							},
						]
						env: [
							{
								name:  "NODE_ENV"
								value: "production"
							},
							{
								name:  "PORT"
								value: "3000"
							},
						]
						resources: {
							requests: {
								cpu:    "200m"
								memory: "256Mi"
							}
							limits: {
								cpu:    "1000m"
								memory: "1Gi"
							}
						}
						livenessProbe: {
							httpGet: {
								path: "/health"
								port: 3000
							}
							initialDelaySeconds: 30
							periodSeconds:       30
						}
						readinessProbe: {
							httpGet: {
								path: "/ready"
								port: 3000
							}
							initialDelaySeconds: 5
							periodSeconds:       5
						}
					}
				}
			}
		}
	}
}

// Generate Kubernetes manifests using our provider
k8sManifests: k8sprovider.#ProviderKubernetes.render & {
	app: webApp
}
