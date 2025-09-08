package example

import (
	corev2 "jacero.io/oam/core/v2alpha1"
	traits "jacero.io/oam/traits/standard"
	k8sprovider "jacero.io/oam/providers/kubernetes"
)

// Example Application with Workload trait
webApp: corev2.#Application & {
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
						volumeMounts: [
							volumes.nginx & {mountPath: "/usr/share/nginx/html"},
						]
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
			traits.#Volume
			volumes: nginx: {
				type:    "configMap"
				name:    "nginx-config"
				config!: configMap.nginx
			}
			traits.#Config
			configMap: nginx: {
				data: {
					"index.html": """
						<!DOCTYPE html>
						<html lang="en">
						<head>
							<meta charset="UTF-8">
							<meta name="viewport" content="width=device-width, initial-scale=1.0">
							<title>Welcome to Nginx!</title>
						</head>
						<body>
							<h1>Success! The Nginx web server is running.</h1>
						</body>
						</html>
						"""
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
						volumeMounts: [
							volumes.main & {mountPath: "/data"},
						]
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
			traits.#Volume
			volumes: main: {
				type:             "volume"
				name:             "api-data"
				size:             "1Gi"
				storageClassName: "standard"
				accessModes: ["ReadWriteOnce"]
			}
		}
	}
}

// Generate Kubernetes manifests using our provider
k8sManifests: k8sprovider.#ProviderKubernetes.render & {
	app: webApp
}
