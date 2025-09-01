package component

// TODO: Implement Secret and ConfigMap rendering

import (
	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
	v2alpha2generic "jacero.io/oam/v2alpha2/component_type/generic"
	v2alpha2compose "jacero.io/oam/v2alpha2/platform/compose"
)

#SimpleWebApp: v2alpha2core.#Component & {
	#metadata: {
		name:        "simple-web-app.core.oam.dev"
		description: "A simple web application component with a web service and a worker."
	}

	#workload: v2alpha2generic.#Webservice

	// Contextual metadata, usually from the application instantiating the component.
	#context: v2alpha2core.#ContextMeta

	properties: #workload.#schema & {
		name: string | *"simple-web-app"
		container: {
			image: {
				repository: _ | *"docker.io/library/nginx"
				tag:        _ | *"latest"
				digest:     _ | *""
			}
			volumeMounts: _ | *[volumes[0] & {mountPath: "/data"}]
		}
		ports: _ | *[{
			name:          "http"
			containerPort: 80
			protocol:      "TCP"
			exposed:       true
			exposedPort:   80
		}]
		volumes: _ | *[{
			type: "volume"
			name: "data"
			size: "1Gi"
		}]
		labels?: [string]: string | int | bool
		labels: {
			"app": name
		}
		annotations?: [string]: string | int | bool
	}

	_labels: {
		if properties.labels != _|_ {
			for k, v in properties.labels {
				labels: "\(k)": "\(v)"
			}
		}
		if #metadata.labels != _|_ {
			for k, v in #metadata.labels {
				labels: "\(k)": "\(v)"
			}
		}
		if #context.labels != _|_ {
			for k, v in #context.labels {
				labels: "\(k)": "\(v)"
			}
		}
	}
	_annotations: {
		if properties.annotations != _|_ {
			for k, v in properties.annotations {
				annotations: "\(k)": "\(v)"
			}
		}
		if #metadata.annotations != _|_ {
			for k, v in #metadata.annotations {
				annotations: "\(k)": "\(v)"
			}
		}
		if #context.annotations != _|_ {
			for k, v in #context.annotations {
				annotations: "\(k)": "\(v)"
			}
		}
	}
	_volumes: [...]
	for vol in properties.volumes {
		_volumes: [{
			if vol.type == "volume" {
				name: "\(properties.name)-\(vol.name)"
			}
		}]
	}
	template: {
		kubernetes: resources: [
			// Create the main Deployment
			v2alpha2k8s.#Deployment & {
				metadata: {
					name: "\(properties.name)"
					if #context.namespace != _|_ {
						namespace: #context.namespace
					}
					_labels
					_annotations
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
								image:           properties.container.image.reference
								imagePullPolicy: properties.container.image.pullPolicy
								if properties.container.imagePullSecrets != _|_ {
									imagePullSecrets: properties.container.imagePullSecrets
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
										containerPort: port.containerPort
										name:          port.name
										protocol:      port.protocol
									}]
								}
								if properties.container.volumeMounts != _|_ {
									volumeMounts: [for v in properties.container.volumeMounts {
										name:      v.name
										mountPath: v.mountPath
										if v.subPath != _|_ {subPath: v.subPath}
										if v.readOnly != _|_ {readOnly: v.readOnly}
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
										name: v.name
										if v.type == "hostPath" {hostPath: {
											path: v.hostPath
											type: v.hostPathType
										}}
										if v.type == "configMap" {configMap: {name: v.configMap}}
										if v.type == "secret" {secret: {name: v.secret}}
										if v.type == "emptyDir" {emptyDir: {}}
										if v.type == "volume" {persistentVolumeClaim: {
											claimName: "\(properties.name)-\(v.name)"
											if v.accessMode != _|_ {
												if v.accessMode == "ReadWrite" {readOnly: false}
												if v.accessMode == "ReadOnly" {readOnly: true}
											}
										}}
									},
								]
							}
						}
					}
				}
			},
			// Create a service with all ports that are exposed
			v2alpha2k8s.#Service & {
				metadata: {
					name: "\(properties.name)"
					if #context.namespace != _|_ {
						namespace: #context.namespace
					}
					_labels
					_annotations
				}
				spec: {
					selector: {
						properties.labels
					}

					#servicePorts: [...]
					for p in properties.ports {
						if p.exposed == true {
							#servicePorts: [{
								name:       p.name
								port:       p.exposedPort
								targetPort: p.containerPort
								protocol:   p.protocol
							}]
						}
					}

					if #servicePorts != _|_ {
						ports: #servicePorts
					}
					type: properties.exposeType
				}
			},
			// Create PersistentVolumeClaim
			for v in properties.volumes {
				if v.type == "volume" {
					v2alpha2k8s.#PersistentVolumeClaim & {
						metadata: {
							name: "\(properties.name)-\(v.name)"
							if #context.namespace != _|_ {
								namespace: #context.namespace
							}
							_labels
							_annotations
						}
						spec: {
							accessModes: v.accessModes
							resources: {
								requests: {
									storage: v.size
								}
							}
							storageClassName: v.storageClassName
						}
					}
				}
			},
		]
		compose: {
			name: _ | *"\(#metadata.name)"
			if #context.name != _|_ && #context.namespace != _|_ {
				name: "\(#context.namespace)-\(#context.name)"
			}
			if #context.name != _|_ && #context.namespace == _|_ {
				name: "\(#context.name)"
			}
			services: {
				"\(properties.name)": (v2alpha2compose.#ContainerSpecToService & {input: properties.container, #name: properties.name}).result
			}
			if properties.volumes != _|_ {
				volumes: (v2alpha2compose.#ToVolumes & {prefix: properties.name, input: properties.volumes}).result
			}
		}
	}
}
