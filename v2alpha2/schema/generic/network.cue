package generic

#CommonPortSpec: {
	// The port that the container will bind to.
	// This must be a valid port number, 0 < x < 65536.
	containerPort!: uint & >=0
	// If specified, this must be an IANA_SVC_NAME and unique within the pod. Each named port in a pod must have a unique name.
	// Name for the port that can be referred to by services.
	name!: string
	// Protocol for port. Must be UDP, TCP, or SCTP. Defaults to "TCP". 
	protocol?: *"TCP" | "UDP" | "SCTP"
	// What host IP to bind the external port to.
	hostIP?: string
	// What port to expose on the host.
	// This must be a valid port number, 0 < x < 65536.
	hostPort?: uint & >=0
	...
}

#ContainerPort: close(#CommonPortSpec)

#Port: close(#CommonPortSpec & {
	// If true, the port will be exposed outside the container. Defaults to false.
	exposed: bool | *false
	if exposed {
		// The port that will be exposed outside the container.
		// exposedPort in combination with exposed must inform the platform of what port to map to the container when exposing.
		// This must be a valid port number, 0 < x < 65536.
		exposedPort!: uint & >=0
	}
})

#ToContainerPort: {
	#input: #Port
	result: #ContainerPort & {
		containerPort: #input.containerPort
		name?:         #input.name
		protocol?:     #input.protocol
		hostIP?:       #input.hostIP
		hostPort?:     #input.hostPort
	}
}
