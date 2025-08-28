package core

import (
	"strings"
)

#DefaultAPIVersion: string | *"core.oam.dev/v2alpha1"

#Object: {
	#apiVersion: #DefaultAPIVersion
	#kind:       string & strings.MinRunes(1) & strings.MaxRunes(254)
	#combinedVersion: string | "\(#apiVersion).\(#kind)"
	#metadata: #ObjectMeta
	...
}

#ObjectMeta: {
	name:       string & strings.MinRunes(1) & strings.MaxRunes(254)
	namespace?: string & strings.MinRunes(1) & strings.MaxRunes(254)
	annotations?: [string]: string | int | bool
	labels?: [string]:      string | int | bool
	...
}