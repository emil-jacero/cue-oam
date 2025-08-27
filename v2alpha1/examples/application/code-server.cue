package application

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1component "jacero.io/oam/v2alpha1/examples/component"
)

#CodeServer: v2alpha1core.#Application & {
	metadata: {
		name:        "code"
		namespace:   "default"
		description: "An application that deploys code-server, a web-based IDE."
		type:        "code-server"
	}

	components: [
		v2alpha1component.#WebService & {
			config: {
				domainName: "example.com"
				mainContainer: {
					name: metadata.name
					image: {
						repository: "lscr.io/linuxserver/code-server"
						tag:        "latest"
						digest:     ""
					}
					resources: {
						requests: {
							cpu:    "0.2"
							memory: "512Mi"
						}
					}
					env: [
						{name: "PUID", value: "1000"},
						{name: "PGID", value: "1000"},
						{name: "TZ", value: "Etc/UTC"},
						{name: "PROXY_DOMAIN", value: "\(metadata.name).\(config.domainName)"},
						{name: "PASSWORD", value: "yourpassword"},
						{name: "PWA_APPNAME", value: "code-server"},
					]

					ports: [
						{
							name:          "http"
							protocol:      "TCP"
							containerPort: 8443
							exposedPort:   8443
						},
					]

					volumes: [
						{
							name:       "config"
							type:       "volume"
							mountPath:  "/config"
						},
						{
							name:       "data"
							type:       "emptyDir"
							mountPath:  "/data"
							size:       "3Gi"
						},
						{
							name:         "docker-socket"
							type:         "hostPath"
							hostPath:     "/var/run/docker.sock"
							mountPath:    "/var/run/docker.sock"
							accessMode:   "ReadOnly"
							hostPathType: "Socket"
						},
					]
				}
			}
		},
	]
	outputs: {
		_name: string
		// Auto-generated if not specified.
		if metadata.name != "" && metadata.namespace != "" {
			_name: "\(metadata.namespace)-\(metadata.name)"
		}
		if metadata.name != "" && metadata.namespace == "" {
			_name: "\(metadata.name)"
		}
		for component in components {
			if component.templates.compose != _|_ {
				compose: name: _name
				compose: component.templates.compose
			}
		}
	}
}
