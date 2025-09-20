package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Job Transformer - Creates Kubernetes Job resources
#JobTransformer: core.#Transformer & {
	creates: "k8s.io/api/batch/v1.Job"

	required: [
		"core.oam.dev/v2alpha2.ContainerSet",
		"core.oam.dev/v2alpha2.DeploymentType",
	]

	optional: [
		"core.oam.dev/v2alpha2.RestartPolicy",
		"core.oam.dev/v2alpha2.HealthCheck",
	]

	// Default values for various traits.
	// These are automatically included for optional traits if not specified in the component.
	defaults: {...} // see #Transformer interface

	registry: trait.#TraitRegistry

	validates: {
		deploymentType: "Job"
	}

	transform: {
		component: core.#Component
		context:   core.#ProviderContext

		// Extract traits with CUE defaults
		let _containerSet = component.containerSet
		let _deploymentType = component.deploymentType
		let _restartPolicy = component.restartPolicy | *defaults.restartPolicy
		let _healthCheck = component.healthCheck | *defaults.healthCheck

		output: [
			schema.#Job & {
				metadata: #GenerateMetadata & {
					_input: {
						name:         component.#metadata.name
						traitMeta:    component.#metadata
						context:      context
						resourceType: "job"
					}
				}
				spec: {
					completions:    _deploymentType.completions | *1
					parallelism:    _deploymentType.parallelism | *1
					backoffLimit:   _deploymentType.backoffLimit | *6
					completionMode: _deploymentType.completionMode | *"NonIndexed"
					suspend:        _deploymentType.suspend | *false

					if _deploymentType.ttlSecondsAfterFinished != _|_ {
						ttlSecondsAfterFinished: _deploymentType.ttlSecondsAfterFinished
					}

					if _deploymentType.activeDeadlineSeconds != _|_ {
						activeDeadlineSeconds: _deploymentType.activeDeadlineSeconds
					}

					template: {
						metadata: labels: {
							"app.kubernetes.io/name":     component.#metadata.name
							"app.kubernetes.io/instance": context.metadata.application.name
						}
						spec: {
							// Jobs should not restart automatically by default
							restartPolicy: _restartPolicy | *"OnFailure"

							containers: [
								for name, container in _containerSet.containers {
									{
										name:  container.name
										image: "\(container.image.repository):\(container.image.tag)"

										if container.ports != _|_ {
											ports: [
												for port in container.ports {
													containerPort: port.targetPort
													if port.name != _|_ {name: port.name}
													if port.protocol != _|_ {protocol: port.protocol}
												},
											]
										}

										if container.env != _|_ {
											env: container.env
										}

										if container.resources != _|_ {
											resources: container.resources
										}

										if container.volumeMounts != _|_ {
											volumeMounts: container.volumeMounts
										}

										if container.healthCheck != _|_ {
											livenessProbe:  container.healthCheck.livenessProbe
											readinessProbe: container.healthCheck.readinessProbe
										}
										if container.healthCheck == _|_ {
											livenessProbe:  _healthCheck.livenessProbe
											readinessProbe: _healthCheck.readinessProbe
										}
									}
								},
							]

							// Add volumes if Volume trait is present
							if component.volumes != _|_ {
								volumes: [
									for volumeName, volume in component.volumes {
										if volume.type == "emptyDir" {
											{
												name: volume.name
												emptyDir: {}
											}
										}
										if volume.type == "configMap" {
											{
												name: volume.name
												configMap: name: volume.configMapName
											}
										}
										if volume.type == "secret" {
											{
												name: volume.name
												secret: secretName: volume.secretName
											}
										}
										if volume.type == "volume" {
											{
												name: volume.name
												persistentVolumeClaim: claimName: "\(component.#metadata.name)-\(volumeName)"
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
