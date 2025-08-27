package component

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1schema "jacero.io/oam/v2alpha1/schema"
	v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
	v2alpha1workload "jacero.io/oam/v2alpha1/examples/workload"
)

#WebService: v2alpha1core.#Component & {

	#metadata: {
		name:        "webservice.component.oam.dev"
		description: "A test component for the web service workload."
		type:        "workload"
		category:    "webservice"
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
			restartPolicy: _ | *"Always"
			// command: _ | *[]
			// args: _ | *[]
			env: _ | *[{name: "ENV", value: "production"}]

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
					name:       "config"
					type:       "volume"
					mountPath:  "/config"
					accessMode: "ReadWrite"
					size:       "1Gi"
				},
			]

			resources: _ | *{
				requests: {
					cpu:    "0.1"
					memory: "128Mi"
				}
			}
		}
	}
	template: {
		compose: {
			name: _ | *"\(#metadata.name)"
			services: {
				"\(config.mainContainer.name)": {
					hostname:       config.mainContainer.name
					container_name: config.mainContainer.name
					domainname:     config.domainName
					image:          config.mainContainer.image.reference
					pull_policy:    (v2alpha1compose.#ToServicePullPolicy & {input: config.mainContainer.image.pullPolicy}).result

					restart: (v2alpha1compose.#ToServiceRestartPolicy & {input: config.mainContainer.restartPolicy}).result

					if config.mainContainer.command != _|_ {
						command: config.mainContainer.command
					}
					if config.mainContainer.args != _|_ {
						args: config.mainContainer.args
					}
					if config.mainContainer.env != _|_ {
						environment: (v2alpha1compose.#ToServiceEnv & {input: config.mainContainer.env}).result
					}

					if config.mainContainer.resources != _|_ {
						// Cannot use v2alpha1compose.#ToServiceDeployResources atm: https://github.com/cue-lang/cue/issues/4037
						// deploy: resources: (v2alpha1compose.#ToServiceDeployResources & {input: config.mainContainer.resources}).result
						deploy: resources: {
							if config.mainContainer.resources.requests != _|_ {
								reservations: {
									if config.mainContainer.resources.requests.cpu != _|_ {
										cpus: (v2alpha1compose.#CPUToCompose & {input: config.mainContainer.resources.requests.cpu}).result
									}
									if config.mainContainer.resources.requests.memory != _|_ {
										memory: (v2alpha1compose.#K8sMemoryToCompose & {input: config.mainContainer.resources.requests.memory}).result
									}
								}
							}
							if config.mainContainer.resources.limits != _|_ {
								limits: {
									if config.mainContainer.resources.limits.cpu != _|_ {
										cpus: (v2alpha1compose.#CPUToCompose & {input: config.mainContainer.resources.limits.cpu}).result
									}
									if config.mainContainer.resources.limits.memory != _|_ {
										memory: (v2alpha1compose.#K8sMemoryToCompose & {input: config.mainContainer.resources.limits.memory}).result
									}
								}
							}
						}
					}
					if config.mainContainer.ports != _|_ {
						ports: (v2alpha1compose.#ToServicePorts & {input: config.mainContainer.ports}).result
					}
					if config.mainContainer.volumes != _|_ {
						volumes: (v2alpha1compose.#ToServiceVolumes & {input: config.mainContainer.volumes}).result
					}
				}
			}
			if config.mainContainer.volumes != _|_ {
				volumes: (v2alpha1compose.#ToVolumes & {prefix: config.mainContainer.name, input: config.mainContainer.volumes}).result
			}
		}
	}
}
