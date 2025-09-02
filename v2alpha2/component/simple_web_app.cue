package component

// TODO: Implement Secret and ConfigMap rendering

import (
	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
	// v2alpha2schemageneric "jacero.io/oam/v2alpha2/schema/generic"
	v2alpha2generic "jacero.io/oam/v2alpha2/component_type/generic"
	v2alpha2platformcompose "jacero.io/oam/v2alpha2/platform/compose"
	v2alpha2platformk8s "jacero.io/oam/v2alpha2/platform/kubernetes"
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
		domainName?: string
		image: {
			repository: _ | *"docker.io/library/nginx"
			tag:        _ | *"latest"
			digest:     _ | *""
		}
		ports: _ | *[{
			name:          "http"
			containerPort: 80
			protocol:      "TCP"
			exposedPort:   8080
		},
		{
			name:          "https"
			containerPort: 443
			protocol:      "TCP"
			exposedPort:   8443
		}]
		volumes: _ | *[{
			type: "volume"
			name: "data"
			size: "1Gi"
			mountPath: "/data"
		}]
		labels: {
			"app": properties.name
		}
	}

	#labels: {
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

	#annotations: {
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

	template: {
		#TCPPorts: [ for p in properties.ports if p.protocol == "TCP" {p}]
		#UDPPorts: [ for p in properties.ports if p.protocol == "UDP" {p}]
		kubernetes: resources: [
			// Create the main Deployment
			v2alpha2k8s.#Deployment & {
				metadata: {
					name: "\(properties.name)"
					if #context.namespace != _|_ {
						namespace: #context.namespace
					}
					#labels
					#annotations
				}
				spec: (v2alpha2platformk8s.#RenderDeploymentSpec & {
							#input: properties
							#selector: properties.labels
							#replicas: properties.replicas
						}).result
			},
			// Create a service with all ports that are exposed
			if len(#TCPPorts) > 0 {
				v2alpha2k8s.#Service & {
					metadata: {
						name: "\(properties.name)-tcp"
						if #context.namespace != _|_ {
							namespace: #context.namespace
						}
						#labels
						#annotations
					}
					spec: (v2alpha2platformk8s.#RenderServiceSpec & {
						#selector: properties.labels
						#ports: #TCPPorts
						#exposeType: properties.exposeType
					}).result
				}
			}
			if len(#UDPPorts) > 0 {
				v2alpha2k8s.#Service & {
					metadata: {
						name: "\(properties.name)-udp"
						if #context.namespace != _|_ {
							namespace: #context.namespace
						}
						#labels
						#annotations
					}
					spec: (v2alpha2platformk8s.#RenderServiceSpec & {
						#selector: properties.labels
						#ports: #UDPPorts
						#exposeType: properties.exposeType
					}).result
				}
			}
			// Create PersistentVolumeClaims
			for v in properties.volumes {
				if v.type == "volume" {
					v2alpha2k8s.#PersistentVolumeClaim & {
						metadata: {
							name: "\(properties.name)-\(v.name)"
							if #context.namespace != _|_ {
								namespace: #context.namespace
							}
							#labels
							#annotations
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
				"\(properties.name)": (v2alpha2platformcompose.#ContainerSpecToService & {input: properties, #name: properties.name}).result
			}
			if properties.volumes != _|_ {
				volumes: (v2alpha2platformcompose.#ToVolumes & {prefix: properties.name, input: properties.volumes}).result
			}
		}
	}
}
