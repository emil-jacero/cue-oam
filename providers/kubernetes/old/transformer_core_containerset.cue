package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
	coreschema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// ContainerSet Transformer - Creates Deployment with containers
#ContainerSetTransformer: core.#Transformer & {
	creates: "k8s.io/api/apps/v1.Deployment"
	
	required: [
		"core.oam.dev/v2alpha2.ContainerSet",
	]
	
	optional: [
		"core.oam.dev/v2alpha2.Replicas",
		"core.oam.dev/v2alpha2.UpdateStrategy", 
		"core.oam.dev/v2alpha2.RestartPolicy",
	]
	
	registry: trait.#TraitRegistry
	
	transform: {
		component: core.#Component
		context:   core.#ProviderContext
		output: {
			let containerSetSpec = component.containerSet
			let meta = component.#metadata
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
						let replicaTrait = {for n, t in component.#metadata.#traits if t.#kind == "Replica" {t}}
						if len(replicaTrait) > 0 {
							let replicaSpec = {for n, t in replicaTrait {component.replica}}
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
						let updateStrategyTrait = {for n, t in component.#metadata.#traits if t.#kind == "UpdateStrategy" {t}}
						if len(updateStrategyTrait) > 0 {
							let strategySpec = {for n, t in updateStrategyTrait {component.updateStrategy}}
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
											image: (coreschema.#ImageTemplate & containerSpec.image).reference
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
												livenessProbe: (#transformProbe & {probe: containerSpec.livenessProbe}).transformedProbe
											}
											if containerSpec.readinessProbe != _|_ {
												readinessProbe: (#transformProbe & {probe: containerSpec.readinessProbe}).transformedProbe
											}
											if containerSpec.startupProbe != _|_ {
												startupProbe: (#transformProbe & {probe: containerSpec.startupProbe}).transformedProbe
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
								let restartPolicyTrait = {for n, t in component.#metadata.#traits if t.#kind == "RestartPolicy" {t}}
								if len(restartPolicyTrait) > 0 {
									let policy = {for n, t in restartPolicyTrait {component.restartPolicy}}
									restartPolicy: policy
								}
								if len(restartPolicyTrait) == 0 {
									restartPolicy: "Always" // Default
								}

								// Check for Volume trait and add volumes to pod spec
								let volumeTrait = {for n, t in component.#metadata.#traits if t.#kind == "Volume" {t}}
								if len(volumeTrait) > 0 {
									volumes: [
										for volumeName, volume in component.volumes {
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
