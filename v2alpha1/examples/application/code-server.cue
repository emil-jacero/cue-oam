package application

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1component "jacero.io/oam/v2alpha1/component"
	// v2alpha1schemak8s "jacero.io/oam/v2alpha1/schema/kubernetes"
	// v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

#Code: v2alpha1core.#Application & {
	#metadata: {
		name:        "code"
		namespace:   "default"
		description: "An application that deploys code-server, a web-based IDE."
		type:        "code-server"
	}

	components: [
		#codeServer,
	]
}

#codeServer: v2alpha1component.#WebService & {
	properties: {
		name: "code"
		domainName: "example.com"

		image: {
			repository: "lscr.io/linuxserver/code-server"
			tag:        "4.103.2"
			digest:     "sha256:d85f12f63fbeb0b91d337f1b9fee0409b057d9fbb106b987305856112dc7873a"
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
			{name: "PROXY_DOMAIN", value: "\(properties.name).\(properties.domainName)"},
			{name: "PASSWORD", value: "yourpassword"},
			{name: "PWA_APPNAME", value: "code-server"},
		]

		ports: [
			{
				name:          "https"
				protocol:      "TCP"
				containerPort: 8443
				servicePort:   8443
				exposed:       true
			},
			{
				name:          "http"
				protocol:      "TCP"
				containerPort: 8080
				exposed:       false
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
