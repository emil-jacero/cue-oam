package component

import (

	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1workload "jacero.io/oam/v2alpha1/workload"
	v2alpha1schema "jacero.io/oam/v2alpha1/schema"
	v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
	// appsv1 "cue.dev/x/k8s.io/api/apps/v1"
	// corev1 "cue.dev/x/k8s.io/api/core/v1"
	// metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// WebService results in a Kubernetes Deployment and Service.
#WebService: v2alpha1core.#Component & {
	#metadata: {
		name:        "webservice"
		category:    "web"
		description: "A containerized workload that exposes a web service."
	}

	workload: v2alpha1workload.#Deployment

	// Contextual metadata, usually from the application instantiating the component.
	context: v2alpha1core.#ObjectMeta

	properties: v2alpha1schema.#ContainerSpec & {
		// The name of the container
		name: string | *"example-webservice"

		labels?: [string]: string | int | bool
		labels: {
			"app.oam.dev/component": properties.name
		}
		annotations?: [string]: string | int | bool

		// Which image would you like to use for your service
		image: {
			repository: _ | *"docker.io/library/nginx"
			tag:        _ | *"latest"
			digest:     _ | *""
		}

		// Specify image pull secrets for your service
		imagePullSecrets?: [...string]

		// Command to run in the container
		command?: [...string]

		// Arguments to the command
		args?: [...string]

		// Environment variables to set in the container
		env?: [...v2alpha1schema.#EnvVar]

		resources?: v2alpha1schema.#ResourceRequirements

		// Specify the ports for your service
		ports?: [...v2alpha1schema.#Port]

		// Specify the volume mounts for your service
		volumes?: [...v2alpha1schema.#Volume]

		// +usage=Instructions for assessing whether the container is alive.
		livenessProbe?: v2alpha1schema.#HealthProbe

		// +usage=Instructions for assessing whether the container is in a suitable state to serve traffic.
		readinessProbe?: v2alpha1schema.#HealthProbe
	}

	template: {
		kubernetes: {
			resources: [
				workload.schema & {
					metadata: {
						labels: properties.labels
						if properties.annotations != _|_ {annotations: properties.annotations}

						if #metadata.labels != _|_ {labels: #metadata.labels}
						if #metadata.annotations != _|_ {annotations: #metadata.annotations}

						if context.labels != _|_ {labels: context.labels}
						if context.annotations != _|_ {annotations: context.annotations}
					}
					spec: {
						selector: matchLabels: properties.labels
						template: {
							metadata: {
								labels: properties.labels
								if properties.annotations != _|_ {
									annotations: properties.annotations
								}
							}
							spec: {
								containers: [{
									name:            properties.name
									image:           properties.image.reference
									imagePullPolicy: properties.image.pullPolicy
									if properties.imagePullSecrets != _|_ {
										imagePullSecrets: properties.imagePullSecrets
									}
									if properties.command != _|_ {
										command: properties.command
									}
									if properties.args != _|_ {
										args: properties.args
									}
									if properties.env != _|_ {
										env: properties.env
									}
									if properties.ports != _|_ {
										ports: [for port in properties.ports {
											(v2alpha1schema.#ToContainerPort & {input: port}).result
										}]
									}
									if properties.volumes != _|_ {
										volumeMounts: [for v in properties.volumes {
											name:      v.name
											mountPath: v.mountPath
											if v.subPath != _|_ {subPath: v.subPath}
											if v.accessMode == "ReadWrite" {readOnly: false}
											if v.accessMode == "ReadOnly" {readOnly: true}
											if v.volumeMountOptions != _|_ {
												mountPropagation: v.volumeMountOptions.mountPropagation
												subPathExpr:      v.volumeMountOptions.subPathExpr
											}
										}]
									}
									if properties.livenessProbe != _|_ {livenessProbe: properties.livenessProbe}
									if properties.readinessProbe != _|_ {readinessProbe: properties.readinessProbe}
								}]
								if properties.volumes != _|_ {
									volumes: [
										for v in properties.volumes {
											name:      v.name
											mountPath: v.mountPath
											if v.subPath != _|_ {
												subPath: v.subPath
											}
											if v.accessMode == "ReadWrite" {
												readOnly: false
											}
											if v.accessMode == "ReadOnly" {
												readOnly: true
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
		compose: {
			name: _ | *"\(#metadata.name)"
			if context.name != _|_ && context.namespace != _|_ {
				name: "\(context.namespace)-\(context.name)"
			}
			if context.name != _|_ && context.namespace == _|_ {
				name: "\(context.name)"
			}
			services: {
				"\(properties.name)": (v2alpha1compose.#ContainerSpecToService & {input: properties}).result
			}
			if properties.mainContainer.volumes != _|_ {
				volumes: (v2alpha1compose.#ToVolumes & {prefix: properties.name, input: properties.volumes}).result
			}
		}
	}
}
