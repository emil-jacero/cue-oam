package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/standard/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ContainerSet Transformer - Creates Deployment with containers
#ContainerSetTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.ContainerSet"
	transform: {
		input:   trait.#ContainerSet
		context: core.#ProviderContext
		output: {
			let containerSetSpec = input.containerSet
			let meta = input.#metadata
			let ctx = context

			resources: [
				// Deployment resource
				schema.#Deployment & {
					metadata: #GenerateMetadata & {
						_input: {
							name:         meta.name
							traitMeta:    meta
							context:      ctx
							resourceType: "deployment"
						}
					}
					spec: {
						// Check for Replica trait and use its count if present
						let replicaTrait = {for n, t in input.#metadata.#traits if t.#kind == "Replica" {t}}
						if len(replicaTrait) > 0 {
							let replicaSpec = {for n, t in replicaTrait {input.replica}}
							replicas: {for n, r in replicaSpec {r.count}}[0]
						}
						if len(replicaTrait) == 0 {
							replicas: 1
						}
						selector: matchLabels: {
							"app.kubernetes.io/name":     meta.name // Name taken from the trait metadata in the component
							"app.kubernetes.io/instance": ctx.metadata.application.name
						}

						// Check for UpdateStrategy trait and configure deployment strategy
						let updateStrategyTrait = {for n, t in input.#metadata.#traits if t.#kind == "UpdateStrategy" {t}}
						if len(updateStrategyTrait) > 0 {
							let strategySpec = {for n, t in updateStrategyTrait {input.updateStrategy}}
							strategy: {
								for n, s in strategySpec {
									type: s.type
									if s.type == "RollingUpdate" && s.rollingUpdate != _|_ {
										rollingUpdate: s.rollingUpdate
									}
								}
							}
						}
						if len(updateStrategyTrait) == 0 {
							// Default strategy
							strategy: {
								type: "RollingUpdate"
								rollingUpdate: {
									maxSurge:       1
									maxUnavailable: 0
								}
							}
						}

						template: {
							metadata: #GenerateMetadata & {
								_input: {
									name:         meta.name + "-pod"
									traitMeta:    meta
									context:      ctx
									resourceType: "pod"
								}
							}
							spec: {
								// Main containers
								containers: [
									for containerName, containerSpec in containerSetSpec.containers {
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
															containerPort: port.targetPort
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
											if containerSpec.volumeMounts != _|_ {
												volumeMounts: containerSpec.volumeMounts
											}
										}
									},
								]
								// Init containers
								if containerSetSpec.init != _|_ {
									initContainers: [
										for containerName, containerSpec in containerSetSpec.init {
											{
												name:  containerSpec.name
												image: "\(containerSpec.image.repository):\(containerSpec.image.tag)"
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
												if containerSpec.volumeMounts != _|_ {
													volumeMounts: containerSpec.volumeMounts
												}
											}
										},
									]
								}

								// Check for RestartPolicy trait and configure restart policy
								let restartPolicyTrait = {for n, t in input.#metadata.#traits if t.#kind == "RestartPolicy" {t}}
								if len(restartPolicyTrait) > 0 {
									let policy = {for n, t in restartPolicyTrait {input.restartPolicy}}
									restartPolicy: policy
								}
								if len(restartPolicyTrait) == 0 {
									restartPolicy: "Always" // Default
								}

								// Check for Volume trait and add volumes to pod spec
								let volumeTrait = {for n, t in input.#metadata.#traits if t.#kind == "Volume" {t}}
								if len(volumeTrait) > 0 {
									volumes: [
										for volumeName, volume in input.volumes {
											if volume.type == "volume" {
												{
													name: volume.name
													persistentVolumeClaim: claimName: "\(meta.name)-\(volumeName)"
												}
											}
											if volume.type == "emptyDir" {
												{
													name: volume.name
													emptyDir: {}
													if volume.medium != _|_ {
														emptyDir: medium: volume.medium
													}
													if volume.sizeLimit != _|_ {
														emptyDir: sizeLimit: volume.sizeLimit
													}
												}
											}
											if volume.type == "configMap" {
												{
													name: volume.name
													configMap: {
														name: volume.config.name
														if volume.config.items != _|_ {
															items: volume.config.items
														}
													}
												}
											}
											if volume.type == "secret" {
												{
													name: volume.name
													secret: {
														secretName: volume.secret.name
														if volume.secret.items != _|_ {
															items: volume.secret.items
														}
													}
												}
											}
											if volume.type == "hostPath" {
												{
													name: volume.name
													hostPath: {
														path: volume.hostPath
														if volume.hostPathType != _|_ {
															type: volume.hostPathType
														}
													}
												}
											}
										},
									]
								}
							}
						}
					}
				},
			]
		}
	}
}

// Expose Transformer - Creates Service for exposed ports
#ExposeTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Expose"
	transform: {
		input:   trait.#Expose
		context: core.#ProviderContext
		output: {
			let exposeSpec = input.expose
			let meta = input.#metadata
			let ctx = context

			resources: [
				// Service resource
				schema.#Service & {
					metadata: #GenerateMetadata & {
						_input: {
							name:         meta.name
							traitMeta:    meta
							context:      ctx
							resourceType: "service"
						}
					}
					spec: {
						// Service type
						if exposeSpec.type != _|_ {
							type: exposeSpec.type
						}
						if exposeSpec.type == _|_ {
							type: "ClusterIP"
						}

						// Selector
						if exposeSpec.selector != _|_ {
							selector: exposeSpec.selector
						}
						if exposeSpec.selector == _|_ {
							selector: {
								"app.kubernetes.io/name":     meta.name
								"app.kubernetes.io/instance": ctx.metadata.application.name
							}
						}

						// Ports
						if exposeSpec.ports != _|_ {
							ports: [
								for p in exposeSpec.ports {
									{
										if p.name != _|_ {
											name: p.name
										}
										if p.exposedPort != _|_ {
											port: p.exposedPort
										}
										if p.exposedPort == _|_ {
											port: p.containerPort
										}
										if p.targetPort != _|_ {
											targetPort: p.targetPort
										}
										if p.targetPort == _|_ {
											targetPort: p.exposedPort
										}
										if p.protocol != _|_ {
											protocol: p.protocol
										}

										// NodePort specific
										if (exposeSpec.type | *"ClusterIP") == "NodePort" && p.nodePort != _|_ {
											nodePort: p.nodePort
										}
									}
								},
							]
						}

						// LoadBalancer specific
						if (exposeSpec.type | *"ClusterIP") == "LoadBalancer" {
							if exposeSpec.loadBalancerIP != _|_ {
								loadBalancerIP: exposeSpec.loadBalancerIP
							}
							if exposeSpec.loadBalancerSourceRanges != _|_ {
								loadBalancerSourceRanges: exposeSpec.loadBalancerSourceRanges
							}
						}
					}
				},
			]
		}
	}
}

// Volume Transformer - Creates PersistentVolumeClaims
#VolumeTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Volume"
	transform: {
		input:   trait.#Volume
		context: core.#ProviderContext
		output: {
			let volumeSpec = input.volumes
			let meta = input.#metadata
			let ctx = context

			resources: [
				for volumeName, volume in volumeSpec
				if volume.type == "volume" {
					schema.#PersistentVolumeClaim & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(volumeName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "persistent-volume-claim"
							}
						}
						spec: {
							if volume.accessModes != _|_ {
								accessModes: volume.accessModes
							}
							if volume.accessModes == _|_ {
								accessModes: ["ReadWriteOnce"]
							}
							resources: requests: storage: volume.size
							if volume.storageClassName != _|_ {
								storageClassName: volume.storageClassName
							}
						}
					}
				},
			]
		}
	}
}

// Secret Transformer - Creates Secret resources
#SecretTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Secret"
	transform: {
		input:   trait.#Secret
		context: core.#ProviderContext
		output: {
			let secretSpec = input.secrets
			let meta = input.#metadata
			let ctx = context

			resources: [
				for secretName, secret in secretSpec {
					schema.#Secret & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(secretName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "secret"
							}
						}
						type: secret.type | *"Opaque"
						if secret.data != _|_ {
							data: secret.data
						}
						if secret.stringData != _|_ {
							stringData: secret.stringData
						}
					}
				},
			]
		}
	}
}

// Config Transformer - Creates ConfigMap resources
#ConfigTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Config"
	transform: {
		input:   trait.#Config
		context: core.#ProviderContext
		output: {
			let configSpec = input.configMap
			let meta = input.#metadata
			let ctx = context

			resources: [
				for configName, config in configSpec {
					schema.#ConfigMap & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(configName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "configmap"
							}
						}
						if config.data != _|_ {
							data: config.data
						}
						if config.binaryData != _|_ {
							binaryData: config.binaryData
						}
					}
				},
			]
		}
	}
}

// NetworkIsolationScope Transformer - Creates NetworkPolicy resources
#NetworkIsolationScopeTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.NetworkIsolationScope"
	transform: {
		input:   trait.#NetworkIsolationScope
		context: core.#ProviderContext
		output: {
			let networkSpec = input.network
			let meta = input.#metadata
			let ctx = context

			resources: [
				schema.#NetworkPolicy & {
					metadata: #GenerateMetadata & {
						_input: {
							traitMeta:    meta
							context:      ctx
							resourceType: "network-policy"
						}
					}
					spec: {
						podSelector: matchLabels: {
							"app.kubernetes.io/name":     meta.name
							"app.kubernetes.io/instance": ctx.metadata.application.name
						}

						// Apply default policies based on isolation level
						if networkSpec.isolation == "strict" {
							policyTypes: ["Ingress", "Egress"]
							ingress: []
							egress: []
						}
						if networkSpec.isolation == "pod" {
							policyTypes: ["Ingress", "Egress"]
							ingress: [{
								from: [{
									podSelector: matchLabels: {
										"app.kubernetes.io/name":     meta.name
										"app.kubernetes.io/instance": ctx.metadata.application.name
									}
								}]
							}]
							egress: [{
								to: [{
									podSelector: matchLabels: {
										"app.kubernetes.io/name":     meta.name
										"app.kubernetes.io/instance": ctx.metadata.application.name
									}
								}]
							}]
						}
						if networkSpec.isolation == "namespace" {
							policyTypes: ["Ingress", "Egress"]
							ingress: [{
								from: [{
									namespaceSelector: matchLabels: {
										"kubernetes.io/metadata.name": ctx.namespace
									}
								}]
							}]
							egress: [{
								to: [{
									namespaceSelector: matchLabels: {
										"kubernetes.io/metadata.name": ctx.namespace
									}
								}]
							}]
						}

						// Note: Custom policies would need to be merged with base policies
						// This is a simplified implementation
						if networkSpec.policies != _|_ && networkSpec.isolation == "none" {
							policyTypes: ["Ingress", "Egress"]
							ingress: []
							egress: []
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
