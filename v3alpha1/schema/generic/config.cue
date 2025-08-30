package schema

import (
	v3alpha1core "jacero.io/oam/v3alpha1/core"
)

#Config: v3alpha1core.#Object & {
	#apiVersion: "schema.oam.dev/v3alpha1"
	#kind:       "Config"

	// Immutable, if true, ensures that data stored in the ConfigMap cannot be updated (only object metadata can be modified).
	immutable?: bool

	// Unencoded raw string data
	data: [string]: string
	// Base64 encoded data
	binaryData?: [string]: string
}
