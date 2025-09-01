package generic

import (
	"strings"

	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2generic "jacero.io/oam/v2alpha2/schema/generic"
)

#Task: v2alpha2core.#ComponentType & {
	#metadata: {
		name:        "task.component-type.core.oam.dev"
		type:        "task"
		description: "Describes short-lived, one-off, containerized tasks that run to completion. They do NOT have network endpoint to receive external network traffic."
	}
	#schema: {
		// The operating system type.
		osType?: string | *"linux" | "windows"
		// The operating system architecture.
		arch?: string | *"amd64" | "i386" | "arm" | "arm64"

		name!: string & strings.MaxRunes(254)

		container: v2alpha2generic.#TaskContainerSpec

		volumes?: [...v2alpha2generic.#Volume]
	}
}
