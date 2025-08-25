package component

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1workload "jacero.io/oam/v2alpha1/workload"
	v2alpha1schema "jacero.io/oam/v2alpha1/workload/schema"
	v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
)

#WebApp: v2alpha1core.#Component & {

	metadata: {
		name:        "webapp.component.oam.dev"
		description: "A test component for the web application workload."
		type:        "webapp"
	}

	workload: v2alpha1workload.#Server

	// Config are used to define the properties of the component,
	/// which can be used by the component owner to configure the outputs.
	config: workload.schema & {
		domainName: _ | *"example.com"
		containers: [mainContainer]
		mainContainer: v2alpha1schema.#ContainerSpec & {
			name: _ | *"test-container"
			image: {
				repository: _ | *"docker.io/library/nginx"
				tag:        _ | *"latest"
				digest:     _ | *""
			}
			// command: _ | *[]
			// args: _ | *[]
			// env: _ | *[{name: "ENV", value: "production"}]

			ports: _ | *[
				{
					name:          "http"
					protocol:      "TCP"
					containerPort: 80
					exposedPort:   8080
				},
			]

			volumes: _ | *[
				{
					name:      "config"
					type:      "volume"
					mountPath: "/config"
					readOnly:  false
				}
			]

			resources: _ | *{
				requests: {
					cpu:    "0.1"
					memory: "128Mi"
				}
			}
		}
	}
	outputs: {
		compose: {
			name: _ | *"\(metadata.name)"
			services: {
				"\(config.containers[0].name)": {
					hostname:   config.mainContainer.name
					container_name: config.mainContainer.name
					domainname: config.domainName
					image:      config.mainContainer.image.reference
					if config.mainContainer.command != _|_ {
						command: config.mainContainer.command
					}
					if config.mainContainer.args != _|_ {
						args: config.mainContainer.args
					}
					if config.mainContainer.env != _|_ {
						for value in config.mainContainer.env {
							environment: {
								"\(value.name)": value.value
							}
						}
					}
					if config.mainContainer.resources != _|_ {
						deploy: {
							resources: {
								reservations: {
									if config.mainContainer.resources.requests != _|_ {
										if config.mainContainer.resources.requests.cpu != _|_ {
											cpus: (v2alpha1compose.#CPUToCompose & {input: config.mainContainer.resources.requests.cpu}).output
										}
										if config.mainContainer.resources.requests.memory != _|_ {
											memory: (v2alpha1compose.#K8sMemoryToCompose & {input: config.mainContainer.resources.requests.memory}).output
										}
									}
								}
								limits: {
									if config.mainContainer.resources.limits != _|_ {
										if config.mainContainer.resources.limits.cpu != _|_ {
											cpus: (v2alpha1compose.#CPUToCompose & {input: config.mainContainer.resources.limits.cpu}).output
										}
										if config.mainContainer.resources.limits.memory != _|_ {
											memory: (v2alpha1compose.#K8sMemoryToCompose & {input: config.mainContainer.resources.limits.memory}).output
										}
									}
								}
							}
						}
					}
					if config.mainContainer.ports != _|_ {
						ports: [
							for port in config.mainContainer.ports {
								{
									name:     port.name
									target:   port.containerPort
									protocol: port.protocol
									if port.exposedPort != _|_ {
										published: port.exposedPort
									}
								}
							},
						]
					}
					if config.mainContainer.volumes != _|_ {
						volumes: [
							for volume in config.mainContainer.volumes {
								if volume.type == "emptyDir" {
									{
										type:      "volume"
										source:    volume.name
										target:    volume.mountPath
										read_only: volume.readOnly
									}
								}
								if volume.type == "hostPath" {
									{
										type:      "bind"
										source:    volume.hostPath
										target:    volume.mountPath
										read_only: volume.readOnly
									}
								}
								if volume.type == "volume" {
									{
										type:      "volume"
										source:    volume.name
										target:    volume.mountPath
										read_only: volume.readOnly
									}
								}
							},
						]
					}
				}
			}
			if config.mainContainer.volumes != _|_ {
				volumes: {
					for volume in config.mainContainer.volumes {
						if volume.type == "emptyDir" {
							"\(volume.name)": {
								name:   "\(config.mainContainer.name)-\(volume.name)"
								driver: "local"
								driver_opts: {
									// TODO: Add uid and gid options
									type:   "tmpfs"
									device: "tmpfs"
									if volume.size != _|_ {
										o: "size=\((v2alpha1compose.#QuantityToCompose & {input: volume.size}).output)"
									}
								}
							}
						}
						if volume.type == "volume" {
							"\(volume.name)": {
								name:   "\(config.mainContainer.name)-\(volume.name)"
								driver: "local"
								if volume.size != _|_ {
									driver_opts: {
										size: (v2alpha1compose.#QuantityToCompose & {input: volume.size}).output
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
