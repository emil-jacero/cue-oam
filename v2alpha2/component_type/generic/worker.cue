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

		name!: string & strings.MaxRunes(254)

		container: v2alpha2generic.#WorkerContainerSpec

		// A list of volumes to mount into the container.
		volumes?: [...v2alpha2generic.#Volume]
	}
}
