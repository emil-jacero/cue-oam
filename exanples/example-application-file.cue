package examples

import (
	core "jacero.io/oam/core/v2alpha2"
	standard "jacero.io/oam/catalog/traits/standard"
)

core.#Application

// To illustrate how we can flatten the application structure when writing in a single file. Treat the whole file as one application definition.
// This could be useful to simplify writing applications for users.
#metadata: {
	name:      "my-app"
	namespace: "default"
	version:   "0.1.0"
	labels: {
		"extra-label": "example"
	}
}
components: {
	web: {
		standard.#ContainerSet
		standard.#RestartPolicy
		standard.#Expose
		containerSet: {
			containers: main: {
				image: {
					repository: "nginx"
					tag:        "latest"
				}
				ports: [expose.ports[0]]
			}
		}
		restartPolicy: "Always"
		expose: {
			ports: [{
				name: "http"
				targetPort: 80
				exposedPort: 8080
				protocol: "TCP"
			}]
		}

		standard.#Volume
		volumes: dataVolume: {
			name: "data-volume"
			type: "volume"
			size: "1Gi"
		}
	}
}
