package examples

import (
	core "jacero.io/oam/core/v2alpha2"
	standard "jacero.io/oam/catalog/traits/standard"
)

core.#Application

// To illustrate how we can flatten the application structure when writing in a single file. Treat the whole file as one application definition.
// This could be useful to simplify writing applications for users.
#metadata: {
	name: "my-app"
}

components: {
	web: {
		standard.#Workload
		workload: {
			containers: main: {
				image: {
					repository?: "docker.io"
					tag:         "latest"
				}
				volumeMounts: [volumes.dataVolume & {mountPath: "/data"}]
			}
		}
		standard.#Volume
		volumes: dataVolume: {
			name: "data-volume"
			type: "emptyDir"
		}
	}
}
