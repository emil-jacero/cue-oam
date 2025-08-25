package core

import (
	"strings"
)

#DefaultAPIVersion: string | *"core.oam.dev/v2alpha1"

#Object: {
	apiVersion: #DefaultAPIVersion
	kind:       string & strings.MaxRunes(256)
	// combinedVersion: string | "\(apiVersion)/\(kind)"
	metadata: {
		name:       string & strings.MaxRunes(256)
		namespace?: string & strings.MaxRunes(256)
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool
		...
	}
	...
}
