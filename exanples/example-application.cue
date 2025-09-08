package examples

import (
	core "jacero.io/oam/core/v2alpha2"
	standard "jacero.io/oam/catalog/traits/standard"
)

// To illustrate how an application can be defined.
myApp: core.#Application & {
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
}
