package generic

import (
	"strings"

	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2generic "jacero.io/oam/v2alpha2/schema/generic"
)

#Worker: v2alpha2core.#ComponentType & {
	#metadata: {
		name:        "worker.component-type.core.oam.dev"
		type:        "worker"
		description: "Describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic."
	}
	#schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"

		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"

		labels?: [string]: string | int | bool
		annotations?: [string]: string | int | bool

		// Name of the service
		N=name!: string & strings.MaxRunes(253)

		// Domain name for the service (optional)
		domainName?: string

		// The container image to use.
		I=image!: v2alpha2generic.#Image

		// Secrets to use when pulling the container image.
		IP=imagePullSecrets?: [...v2alpha2generic.#Secret]

		// Command to run in the container.
		C=command?: [...string]

		// Arguments to pass to the command.
		A=args?: [...string]

		// List of environment variables to set in the container.
		E=env?: [...v2alpha2generic.#EnvVar]

		// Resources required by the container.
		// Requests describes the minimum amount of compute resources required.
		// If Requests is omitted for a container, it defaults to an implementation-defined value.
		// Limits describes the maximum amount of compute resources allowed.
		// If Limits is omitted for a container, it defaults to an implementation-defined value.
		// Requests cannot exceed Limit#schema.
		R=resources?: v2alpha2generic.#ResourceRequirements

		// The number of replicas of the main container.
		replicas?: uint | *1

		// Each port must have a unique name within the container.
		// If a port is not specified, the container runtime's default will be used.
		P=ports?: [...v2alpha2generic.#Port]
		
		// Specify what kind of Service you want. options: "ClusterIP", "NodePort", "LoadBalancer"
		// Ignored by Docker Compose.
		exposeType: *"ClusterIP" | "NodePort" | "LoadBalancer"

		// Volumes that can be mounted into the container.
		// The volume can be defined here or passed in here from another definition inheriting from #Volume.
		V=volumes?: [...v2alpha2generic.#Volume]

		// The main container for the web service.
		container: v2alpha2generic.#ContainerSpec & {
			name: N
			image: I
			if IP != _|_ {imagePullSecrets: IP}
			if C != _|_ {command: C}
			if A != _|_ {args: A}
			if E != _|_ {env: E}
			if R != _|_ {resources: R}
			if P != _|_ {ports: P}
			if V != _|_ {volumes: V}
			restartPolicy: _ | *"Always"
		}

		// List of containers to add after the main container.
		sidecarContainers?: [...v2alpha2generic.#ContainerSpec]

		// List of init containers to run before the main container.
		initContainers?: [...v2alpha2generic.#ContainerSpec]
	}
}
