package composite

import (
	core "jacero.io/oam/core/v2alpha2"
	workload "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/workload"
	connectivity "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/connectivity"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Webservice defines a basic stateless workload with service exposure
#Webservice: core.#Trait & {
	#metadata: #traits: Webservice: core.#TraitMetaComposite & {
		#kind:       "Webservice"
		description: "Basic stateless workload with internal service exposure"
		domain:      "operational"
		scope: ["component"]
		composes: [
			workload.#DeploymentMeta,
			connectivity.#ServiceMeta,
		]
		provides: {webservice: #Webservice.webservice}
	}

	// Labels for selectors
	labels: [string]: string
	L=labels: {
		"app.kubernetes.io/name": #metadata.name
	}

	// Simplified webservice configuration
	webservice: {
		// Main container configuration
		image!: {
			repository!: string
			tag!:        string
		}

		// Port configuration
		port?: int | *80

		// Replica configuration
		replicas?: int | *1

		// Environment variables for main container
		env?: [...{
			name!:  string
			value!: string
		}]

		// Sidecar containers
		sidecars?: [...{
			name!: string
			image!: {
				repository!: string
				tag!:        string
			}
			ports?: [...{
				containerPort!: int
				protocol?:      string | *"TCP"
			}]
			command?: [...string]
			args?: [...string]
			env?: [...{
				name!:  string
				value!: string
			}]
		}]

		// Init containers
		initContainers?: [...{
			name!: string
			image!: {
				repository!: string
				tag!:        string
			}
			command?: [...string]
			args?: [...string]
			env?: [...{
				name!:  string
				value!: string
			}]
		}]
	}

	// Generate deployment configuration from webservice
	deployment: schema.#DeploymentSpec & {
		replicas: webservice.replicas
		selector: matchLabels: L
		template: {
			metadata: labels: L
			spec: {
				// Init containers
				if webservice.initContainers != _|_ {
					initContainers: [
						for initContainer in webservice.initContainers {
							name:  initContainer.name
							image: "\(initContainer.image.repository):\(initContainer.image.tag)"
							if initContainer.command != _|_ {
								command: initContainer.command
							}
							if initContainer.args != _|_ {
								args: initContainer.args
							}
							if initContainer.env != _|_ {
								env: initContainer.env
							}
						},
					]
				}

				// Main container + sidecars
				containers: [
					// Main container
					{
						name:  #metadata.name
						image: "\(webservice.image.repository):\(webservice.image.tag)"
						if webservice.port != _|_ {
							ports: [{
								containerPort: webservice.port
								protocol:      "TCP"
							}]
						}
						if webservice.env != _|_ {
							env: webservice.env
						}
					},
					// Sidecar containers
					if webservice.sidecars != _|_ {
						for sidecar in webservice.sidecars {
							name:  sidecar.name
							image: "\(sidecar.image.repository):\(sidecar.image.tag)"
							if sidecar.ports != _|_ {
								ports: sidecar.ports
							}
							if sidecar.env != _|_ {
								env: sidecar.env
							}
						}
					},
				]
			}
		}
	}

	// Generate service configuration from webservice
	services: "\(#metadata.name)": schema.#ServiceSpec & {
		selector: L
		if webservice.port != _|_ {
			ports: [{
				name:       "http"
				port:       webservice.port
				targetPort: webservice.port
				protocol:   "TCP"
			}]
		}
	}
}

#WebserviceMeta: #Webservice.#metadata.#traits.Webservice
