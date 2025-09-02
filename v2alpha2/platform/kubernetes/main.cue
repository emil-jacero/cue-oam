package kubernetes

import (
	componenttype "jacero.io/oam/v2alpha2/component_type/generic"
	schemak8s "jacero.io/oam/v2alpha2/schema/kubernetes"
	schemageneric "jacero.io/oam/v2alpha2/schema/generic"
)

// Deployment renderer.
#RenderDeploymentSpec: {
	#input!: componenttype.#Webservice.#schema
	#selector!: {[string]: string}
	#replicas!: uint
	result: schemak8s.#DeploymentSpec & {
		if #input.replicas != _|_ {replicas: #input.replicas}
		selector: matchLabels: #selector
		template: {
			metadata: labels: #selector
			spec: {
				containers: [{
					name: #input.container.name
					// image: #input.container.image.reference
					if #input.container.command != _|_ {command: #input.container.command}
					if #input.container.args != _|_ {args: #input.container.args}

					if #input.container.env != _|_ {env: [for e in #input.container.env {name: e.name, value: e.value}]}
					if #input.container.ports != _|_ {ports: [for p in #input.container.ports {
						containerPort: p.containerPort
						name:          p.name
						protocol:      p.protocol
						if p.hostIP != _|_ {hostIP: p.hostIP}
						if p.hostPort != _|_ {hostPort: p.hostPort}
					}]}

					if #input.container.livenessProbe != _|_ {livenessProbe: #input.container.livenessProbe}
					if #input.container.readinessProbe != _|_ {readinessProbe: #input.container.readinessProbe}
					if #input.container.startupProbe != _|_ {startupProbe: #input.container.startupProbe}

					if #input.container.resources != _|_ {resources: #input.container.resources}
					if #input.container.tty != _|_ {tty: #input.container.tty}
					if #input.container.workingDir != _|_ {workingDir: #input.container.workingDir}
				}]
				// volumes
				if #input.container.volumes != _|_ {
					volumes: [
						for v in #input.container.volumes {
							name: v.name
							if v.type == "hostPath" {hostPath: {
								path: v.hostPath
								type: v.hostPathType
							}}
							if v.type == "configMap" {configMap: {name: v.configMap}}
							if v.type == "secret" {secret: {name: v.secret}}
							if v.type == "emptyDir" {emptyDir: {}}
							if v.type == "volume" {persistentVolumeClaim: {
								claimName: "\(#input.name)-\(v.name)"
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
}

// Render a service spec
// If 
#RenderServiceSpec: {
	#ports!: [...schemageneric.#Port]
	#exposeType!: string & "ClusterIP" | "NodePort" | "LoadBalancer"
	#selector!: {[string]: string}
	result: schemak8s.#ServiceSpec & {
		selector: #selector
		ports: [for p in #ports if p.exposedPort != _|_ {
			name:       p.name
			port:       p.exposedPort
			targetPort: p.containerPort
			protocol:   p.protocol
		}]
		type: #exposeType
	}
}
