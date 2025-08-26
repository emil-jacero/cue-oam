package schema

#Port: {
	// If specified, this must be an IANA_SVC_NAME and unique within the pod. Each named port in a pod must have a unique name.
	// Name for the port that can be referred to by services.
	name: string
	// Protocol for port. Must be UDP, TCP, or SCTP. Defaults to "TCP". 
	protocol: *"TCP" | "UDP" | "SCTP"
	// The port that the container will bind to.
	// This must be a valid port number, 0 < x < 65536.
	containerPort: uint & >=0
	// The port that will be exposed outside the container.
	// This must be a valid port number, 0 < x < 65536.
	// When setting this field, a transformer must ensure this port is exposed by the underlying platform.
	exposedPort?: uint & >=0
	// Optional port number to bind the port to on the host
	nodePort?: uint & >=0
}
