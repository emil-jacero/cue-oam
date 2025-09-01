package generic

import (
	"strings"

	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2generic "jacero.io/oam/v2alpha2/schema/generic"
)

#Webservice: v2alpha2core.#ComponentType & {
	#metadata: {
		name:        "webservice.component-type.core.oam.dev"
		type:        "webservice"
		description: "Service-oriented components are components that support external access to services with the container as the core, and their functions cover the needs of most of the microservice scenarios."
	}
	#schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"
		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"

		name!: string & strings.MaxRunes(254)

		container: v2alpha2generic.#WebserviceContainerSpec

		// Specify what kind of Service you want. options: "ClusterIP", "NodePort", "LoadBalancer"
		// Ignored by Docker Compose.
		exposeType: *"ClusterIP" | "NodePort" | "LoadBalancer"

		// A list of ports to expose from the container.
		ports?: [...v2alpha2generic.#Port]

		// A list of volumes to mount into the container.
		volumes?: [...v2alpha2generic.#Volume]

		labels?: [string]:      string | int | bool
		annotations?: [string]: string | int | bool
	}
}
