package application

import (
	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2component "jacero.io/oam/v2alpha2/component"
	// v2alpha2trait "jacero.io/oam/v2alpha2/trait"
)

#CodeServer: v2alpha2core.#Application & {
	#metadata: {
		name:        "code-server"
		description: "An example application using the code-server component."
	}
	#components: [v2alpha2component.#SimpleWebApp & {
		properties: {
			name:       "code-server"
			domainName: "example.com"
			container: {
				image: {
					repository: "lscr.io/linuxserver/code-server"
					tag:        "4.103.2"
					digest:     "sha256:d85f12f63fbeb0b91d337f1b9fee0409b057d9fbb106b987305856112dc7873a"
				}
				env: [
					{name: "PUID", value: "1000"},
					{name: "PGID", value: "1000"},
					{name: "TZ", value: "Etc/UTC"},
					{name: "PROXY_DOMAIN", value: "\(properties.name).\(properties.domainName)"},
					{name: "PASSWORD", value: "yourpassword"},
					{name: "PWA_APPNAME", value: "code-server"},
				]
				resources: {
					requests: {
						cpu:    "1"
						memory: "1Gi"
					}
				}
				ports:        P
				volumeMounts: volumes
			}
			P=ports: [
				{
					name:          "https"
					protocol:      "TCP"
					containerPort: 8443
					exposedPort:   8443
				},
				{
					name:          "http"
					protocol:      "TCP"
					containerPort: 8080
				},
			]
			volumes: [
				{
					name:      "config"
					type:      "volume"
					size:      "1Gi"
					mountPath: "/config"
				},
				{
					name:      "data"
					type:      "volume"
					size:      "10Gi"
					mountPath: "/data"
				},
				{
					name:         "docker-socket"
					type:         "hostPath"
					hostPath:     "/var/run/docker.sock"
					mountPath:    "/var/run/docker.sock"
					readOnly:     true
					hostPathType: "Socket"
				},
			]
		}
	}]
}
