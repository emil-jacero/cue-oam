package application

import (
	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2component "jacero.io/oam/v2alpha2/component"
	v2alpha2trait "jacero.io/oam/v2alpha2/trait"
)

#Podinfo: v2alpha2core.#Application & {
	#metadata: {
		name:        "podinfo"
		description: "An example application using the podinfo component."
	}
	#components: [v2alpha2component.#SimpleWebApp & {
		properties: {
			name: "podinfo"
			image: {
				repository: "stefanprodan/podinfo"
				tag:        "6.0.0"
			}
			ports: [{
				name:          "http"
				containerPort: 9898
				protocol:      "TCP"
				exposedPort:   9898
			}]
			volumes: [{
				type:      "volume"
				name:      "data"
				size:      "1Gi"
				mountPath: "/data"
			}]
		}
		traits: [
			v2alpha2trait.#Labels & {properties: {
				"example/name":        "podinfo"
				"example/description": "An example application using the podinfo component."
				"example/version":     "1.0.0"
			}},
			v2alpha2trait.#Annotations & {properties: {
				"example/annotation": "This is an example annotation for the podinfo component."
			}},
		]
	}]
}
