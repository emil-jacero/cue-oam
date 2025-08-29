package compose

import (
	"strconv"
	"strings"

	v2alpha1schema "jacero.io/oam/v2alpha1/schema"
	v2alpha1compose "jacero.io/oam/v2alpha1/schema/compose"
)

#ContainerSpecToService: {
	I=input!: v2alpha1schema.#ContainerSpec
	result: v2alpha1compose.#Service & {
		hostname:       I.name
		container_name: I.name
		image:          I.image.reference
		pull_policy: (#ToServicePullPolicy & {input: I.image.pullPolicy}).result

		if I.restartPolicy != _|_ {
			restart: (#ToServiceRestartPolicy & {input: I.restartPolicy}).result
		}

		if I.command != _|_ {
			command: I.command
		}

		if I.args != _|_ {
			args: I.args
		}

		if I.env != _|_ {
			environment: (#ToServiceEnv & {input: I.env}).result
		}

		// Cannot use #ToServiceDeployResources because of a bug: https://github.com/cue-lang/cue/issues/4037
		// if I.resources != _|_ {
		// 	// deploy: resources: (#ToServiceDeployResources & {input: I.resources}).result
		// 	deploy: resources: {
		// 		if I.resources.requests != _|_ {
		// 			reservations: {
		// 				if I.resources.requests.cpu != _|_ {
		// 					cpus: (#CPUToCompose & {input: I.resources.requests.cpu}).result
		// 				}
		// 				if I.resources.requests.memory != _|_ {
		// 					memory: (#K8sMemoryToCompose & {input: I.resources.requests.memory}).result
		// 				}
		// 			}
		// 		}
		// 		if I.resources.limits != _|_ {
		// 			limits: {
		// 				if I.resources.limits.cpu != _|_ {
		// 					cpus: (#CPUToCompose & {input: I.resources.limits.cpu}).result
		// 				}
		// 				if I.resources.limits.memory != _|_ {
		// 					memory: (#K8sMemoryToCompose & {input: I.resources.limits.memory}).result
		// 				}
		// 			}
		// 		}
		// 	}
		// }

		if I.ports != _|_ {
			ports: [
				for port in I.ports {
					{
						name:     port.name
						target:   port.containerPort
						protocol: port.protocol

						if port.exposed {
							published: port.servicePort
						}
					}
				},
			]
		}

		if I.volumes != _|_ {
			volumes: (#ToServiceVolumes & {input: I.volumes}).result
		}
	}
}

#ToServicePullPolicy: {
	I=input!: v2alpha1schema.#PullPolicy
	result: v2alpha1compose.#PullPolicy & {
		if I == "IfNotPresent" {
			"if_not_present"
		}
		if I == "Always" {
			"always"
		}
		if I == "Never" {
			"never"
		}
	}
}

#ToServiceRestartPolicy: {
	I=input!: v2alpha1schema.#RestartPolicy
	result: v2alpha1compose.#RestartPolicy & {
		if I == "Always" {
			"always"
		}
		if I == "OnFailure" {
			"on-failure"
		}
		if I == "Never" {
			"no"
		}
	}
}

#ToServiceEnv: {
	I=input!: [...v2alpha1schema.#EnvVar]
	result: v2alpha1compose.#list_or_dict & {
		for value in I {
			{"\(value.name)": value.value}
		}
	}
}

#ToServiceDeployResources: {
	I=input!: v2alpha1schema.#ResourceRequirements
	// v2alpha1compose.#deployment.resources & 
	result: {
		if I.requests != _|_ {
			reservations: {
				if I.requests.cpu != _|_ {
					cpus: (#CPUToCompose & {input: I.requests.cpu}).result
				}
				if I.requests.memory != _|_ {
					memory: (#K8sMemoryToCompose & {input: I.requests.memory}).result
				}
			}
		}
		if I.limits != _|_ {
			limits: {
				if I.limits.cpu != _|_ {
					cpus: (#CPUToCompose & {input: I.limits.cpu}).result
				}
				if I.limits.memory != _|_ {
					memory: (#K8sMemoryToCompose & {input: I.limits.memory}).result
				}
			}
		}
	}
}

#ToServicePorts: {
	I=input!: [...v2alpha1schema.#Port]
	result: [
		for port in I {
			{
				name:     port.name
				target:   port.containerPort
				protocol: port.protocol
				if port.expose != _|_ {
					if port.expose {
						if port.servicePort != _|_ {
							published: port.servicePort
						}
					}
				}
			}
		},
	]
}

#ToServiceVolumes: {
	I=input!: [...v2alpha1schema.#Volume]
	result: [
		for volume in I {
			if volume.accessMode != _|_ {
				if volume.accessMode == "ReadOnly" {
					read_only: true
				}
				if volume.accessMode == "ReadWrite" {
					read_only: false
				}
			}
			if volume.type == "emptyDir" {
				{
					type:   "volume"
					source: volume.name
					target: volume.mountPath
				}
			}
			if volume.type == "hostPath" {
				{
					type:   "bind"
					source: volume.hostPath
					target: volume.mountPath
				}
			}
			if volume.type == "volume" {
				{
					type:   "volume"
					source: volume.name
					target: volume.mountPath
				}
			}
		},
	]
}

#ToVolumes: {
	P=prefix!: string
	I=input!: [...v2alpha1schema.#Volume]
	result: {
		for volume in I {
			if volume.type == "emptyDir" {
				"\(volume.name)": {
					name:   "\(P)-\(volume.name)"
					driver: "local"
					driver_opts: {
						// TODO: Add uid and gid options
						type:   "tmpfs"
						device: "tmpfs"
						if volume.size != _|_ {
							o: "size=\((#QuantityToCompose & {input: volume.size}).result)"
						}
					}
				}
			}
			if volume.type == "volume" {
				"\(volume.name)": {
					name:   "\(P)-\(volume.name)"
					driver: "local"
				}
			}
		}
	}
}

#QuantityToCompose: {
	input:  string
	result: #Quantity
	if strings.HasSuffix(input, "Ki") {result: "\(strings.TrimSuffix(input, "Ki"))k"}
	if strings.HasSuffix(input, "Mi") {result: "\(strings.TrimSuffix(input, "Mi"))m"}
	if strings.HasSuffix(input, "Gi") {result: "\(strings.TrimSuffix(input, "Gi"))g"}
	if strings.HasSuffix(input, "Ti") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)g"}
	if strings.HasSuffix(input, "Pi") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)g"}
	if strings.HasSuffix(input, "Ei") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)g"}
	resultLong: #Quantity
	if strings.HasSuffix(input, "Ki") {resultLong: "\(strings.TrimSuffix(input, "Ki"))kb"}
	if strings.HasSuffix(input, "Mi") {resultLong: "\(strings.TrimSuffix(input, "Mi"))mb"}
	if strings.HasSuffix(input, "Gi") {resultLong: "\(strings.TrimSuffix(input, "Gi"))gb"}
	if strings.HasSuffix(input, "Ti") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)gb"}
	if strings.HasSuffix(input, "Pi") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)gb"}
	if strings.HasSuffix(input, "Ei") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)gb"}
}

// ComposeQuantity is a string that is validated as a quantity for Docker Compose resource limits and reservations.
// Valid units are: k, m, g, kb, mb, gb (case insensitive).
// More info: https://docs.docker.com/reference/compose-file/deploy/#resources
// More info: https://docs.docker.com/reference/compose-file/extension/#specifying-byte-values
#Quantity: string & =~"^[1-9]\\d*(k|m|g|kb|mb|gb)?$"

// MemoryToCompose converts Kubernetes-style memory quantities (e.g. "128Mi", "2Gi") to Docker Compose-style quantities (e.g. "128m", "2g").
#K8sMemoryToCompose: {
	input:  string
	result: #Quantity
	if strings.HasSuffix(input, "Ki") {result: "\(strings.TrimSuffix(input, "Ki"))k"}
	if strings.HasSuffix(input, "Mi") {result: "\(strings.TrimSuffix(input, "Mi"))m"}
	if strings.HasSuffix(input, "Gi") {result: "\(strings.TrimSuffix(input, "Gi"))g"}
	if strings.HasSuffix(input, "Ti") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)g"}
	if strings.HasSuffix(input, "Pi") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)g"}
	if strings.HasSuffix(input, "Ei") {result: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)g"}
	resultLong: #Quantity
	if strings.HasSuffix(input, "Ki") {resultLong: "\(strings.TrimSuffix(input, "Ki"))kb"}
	if strings.HasSuffix(input, "Mi") {resultLong: "\(strings.TrimSuffix(input, "Mi"))mb"}
	if strings.HasSuffix(input, "Gi") {resultLong: "\(strings.TrimSuffix(input, "Gi"))gb"}
	if strings.HasSuffix(input, "Ti") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)gb"}
	if strings.HasSuffix(input, "Pi") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)gb"}
	if strings.HasSuffix(input, "Ei") {resultLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)gb"}
}

// MemoryQuantity is a string that is validated as a quantity of memory, such as 128m, 128mb or 2g.
// Valid units are: k, m, g, kb, mb, gb (case insensitive).
// More info: https://docs.docker.com/reference/compose-file/deploy/#resources
// More info: https://docs.docker.com/reference/compose-file/extension/#specifying-byte-values
#MemoryQuantity: string & =~"^[1-9]\\d*(k|m|g|kb|mb|gb)?$"

// Convert "100m", "250m", 0.5, 1 -> "0.1", "0.25", "0.5", "1"
#CPUToCompose: {
	input: string

	// Final output guaranteed to be a decimal-cores string
	result: string & #ComposeCpus

	// mCPU -> cores
	if strings.HasSuffix(input, "m") {
		_m:     int & strconv.Atoi(strings.TrimSuffix(input, "m"))
		result: "\(_m/1000.0)"
	}

	// plain int/float string or numeric -> pass through normalized
	if !strings.HasSuffix(input, "m") {
		result: "\(strconv.ParseFloat(input, 2))"
	}
}

// Decimal cores string for Compose deploy.resources.*.cpus
#ComposeCpus: =~"^[0-9]+(\\.[0-9]+)?$"
