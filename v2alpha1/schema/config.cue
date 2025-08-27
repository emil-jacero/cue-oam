package schema

import (
	v2alpha1core "jacero.io/oam/v2alpha1/core"
)

#ConfigMap: v2alpha1core.#Object & {
	#apiVersion: "schema.oam.dev/v2alpha1"
	#kind:       "ConfigMap"

	// Immutable, if true, ensures that data stored in the ConfigMap cannot be updated (only object metadata can be modified).
	immutable?: bool

	// Unencoded raw string data
	data: [string]: string
	// Base64 encoded data
	binaryData?: [string]: string
}
