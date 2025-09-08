package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/standard"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#ProviderKubernetes: core.#Provider & {
	#metadata: {
		name:        "Kubernetes"
		description: "Provider that renders resources for Kubernetes."
		minVersion:  "v1.31.0" // Minimum supported Kubernetes version
		capabilities: [
			// Supported OAM core types
			"core.oam.dev/v2alpha2.Workload",
			"core.oam.dev/v2alpha2.Database",
			"core.oam.dev/v2alpha2.Volume",
			"core.oam.dev/v2alpha2.Secret",
			"core.oam.dev/v2alpha2.Config",
			"core.oam.dev/v2alpha2.Route",
			"core.oam.dev/v2alpha2.Replicable",
			"core.oam.dev/v2alpha2.Scalable",

			// Supported Kubernetes resources
			"k8s.io/api/core/v1.Pod",
			"k8s.io/api/core/v1.Service",
			"k8s.io/api/apps/v1.Deployment",
			"k8s.io/api/apps/v1.StatefulSet",
			"k8s.io/api/apps/v1.DaemonSet",
			"k8s.io/api/batch/v1.Job",
			"k8s.io/api/batch/v1.CronJob",
			"k8s.io/api/rbac/v1.Role",
			"k8s.io/api/rbac/v1.RoleBinding",
			"k8s.io/api/networking/v1.Ingress",
			"k8s.io/api/core/v1.ConfigMap",
			"k8s.io/api/core/v1.Secret",
			"k8s.io/api/core/v1.PersistentVolumeClaim",
		]
	}

	transformers: {
		"core.oam.dev/v2alpha2.Workload": #WorkloadTransformer
		// "core.oam.dev/v2alpha2.Volume":   #VolumeTransformer
		// "core.oam.dev/v2alpha2.Secret":   #SecretTransformer
		// "core.oam.dev/v2alpha2.Config":   #ConfigTransformer
	}

	render: {
		app: core.#Application
		output: {
			resources: [
				// Flatten all transformer outputs into a single array
				for componentName, component in app.components
				for traitName, trait in component.#metadata.#traits
				if transformers[trait.#combinedVersion] != _|_
				for resource in (transformers[trait.#combinedVersion].transform & {
					input: component
					context: core.#ProviderContext & {
						namespace:     app.#metadata.namespace
						appName:       app.#metadata.name
						appVersion:    app.#metadata.version
						appLabels:     app.#metadata.labels
						componentName: componentName
						componentId:   component.#metadata.#id
						capabilities:  #metadata.capabilities
					}
				}).output.resources {
					resource
				},
			]
		}
	}
}

#WorkloadTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Workload"
	transform: {
		input:   trait.#Workload
		context: core.#ProviderContext
		output: {
			let workloadSpec = input.workload
			let meta = input.#metadata
			let ctx = context

			resources: [
				// Deployment resource
				schema.#Deployment & {
					metadata: {
						name:      meta.name
						namespace: ctx.namespace
						labels: {
							"app.kubernetes.io/name":       meta.name
							"app.kubernetes.io/managed-by": "cue-oam"
							"app.kubernetes.io/instance":   ctx.appName
							"app.kubernetes.io/version":    ctx.appVersion
						} & ctx.appLabels
						if meta.annotations != _|_ {
							annotations: meta.annotations
						}
					}
					spec: {
						if workloadSpec.replicas != _|_ {
							replicas: workloadSpec.replicas
						}
						if workloadSpec.replicas == _|_ {replicas: 1}
						selector: matchLabels: {
							"app.kubernetes.io/name":     meta.name
							"app.kubernetes.io/instance": ctx.appName
							"app.kubernetes.io/version":  ctx.appVersion
						}
						template: {
							metadata: labels: {
								"app.kubernetes.io/name":     meta.name
								"app.kubernetes.io/instance": ctx.appName
								"app.kubernetes.io/version":  ctx.appVersion
							} & ctx.appLabels
							spec: {
								containers: [
									for containerName, containerSpec in workloadSpec.containers {
										{
											name:  containerSpec.name
											image: "\(containerSpec.image.repository):\(containerSpec.image.tag)"
											if containerSpec.ports != _|_ {
												ports: [
													for port in containerSpec.ports {
														{
															if port.name != _|_ {
																name: port.name
															}
															containerPort: port.containerPort
															if port.protocol != _|_ {
																protocol: port.protocol
															}
														}
													},
												]
											}
											if containerSpec.env != _|_ {
												env: [
													for envVar in containerSpec.env {
														{
															name:  envVar.name
															value: envVar.value
														}
													},
												]
											}
											if containerSpec.resources != _|_ {
												resources: containerSpec.resources
											}
											if containerSpec.livenessProbe != _|_ {
												livenessProbe: (_transformProbe & {probe: containerSpec.livenessProbe}).transformedProbe
											}
											if containerSpec.readinessProbe != _|_ {
												readinessProbe: (_transformProbe & {probe: containerSpec.readinessProbe}).transformedProbe
											}
											if containerSpec.startupProbe != _|_ {
												startupProbe: (_transformProbe & {probe: containerSpec.startupProbe}).transformedProbe
											}
										}
									},
								]
							}
						}
					}
				},

				// Service resource - generated for workloads with exposed ports
				schema.#Service & {
					metadata: {
						name:      meta.name
						namespace: ctx.namespace
						labels: {
							"app.kubernetes.io/name":       meta.name
							"app.kubernetes.io/managed-by": "cue-oam"
							"app.kubernetes.io/instance":   ctx.appName
							"app.kubernetes.io/version":    ctx.appVersion
						} & ctx.appLabels
					}
					spec: {
						selector: {
							"app.kubernetes.io/name":     meta.name
							"app.kubernetes.io/instance": ctx.appName
						}
						for containerName, containerSpec in workloadSpec.containers
						if containerSpec.ports != _|_ {
							ports: [
								for p in containerSpec.ports {
									{
										name:       p.name
										targetPort: p.containerPort
										protocol:   p.protocol

										// If exposedPort is specified, use that
										if p.exposedPort != _|_ {port: p.exposedPort}

										// If exposedPort is not specified, use containerPort
										if p.exposedPort == _|_ {port: p.containerPort}
									}
								},
							]
						}

					}
				},
			]
		}
	}
}

// Helper functions
let _transformProbe = {
	probe: _
	transformedProbe: {
		if probe.httpGet != _|_ {
			httpGet: {
				if probe.httpGet.path != _|_ {path: probe.httpGet.path}
				port: probe.httpGet.port
				if probe.httpGet.scheme != _|_ {scheme: probe.httpGet.scheme}
			}
		}
		if probe.tcpSocket != _|_ {
			tcpSocket: port: probe.tcpSocket.port
		}
		if probe.exec != _|_ {
			exec: {
				if probe.exec.command != _|_ {command: probe.exec.command}
			}
		}
		if probe.initialDelaySeconds != _|_ {initialDelaySeconds: probe.initialDelaySeconds}
		if probe.periodSeconds != _|_ {periodSeconds: probe.periodSeconds}
		if probe.timeoutSeconds != _|_ {timeoutSeconds: probe.timeoutSeconds}
		if probe.successThreshold != _|_ {successThreshold: probe.successThreshold}
		if probe.failureThreshold != _|_ {failureThreshold: probe.failureThreshold}
	}
}
