package generic

import (
	"strings"
)

#Config: #ConfigSpec & {
	name!: string & strings.MinRunes(1) & strings.MaxRunes(254)
}

#ConfigSpec: {
	// Immutable, if true, ensures that data stored in the ConfigMap cannot be updated (only object metadata can be modified).
	immutable?: bool

	// Unencoded raw string data
	data: [string]: string
	// Base64 encoded data
	binaryData?: [string]: string
}
