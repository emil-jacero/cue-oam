package v2alpha1

import (
	"strings"
)

// Base types and metadata definitions
#NameType:      string & strings.MinRunes(1) & strings.MaxRunes(254)
#VersionType:   string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

#LabelsType: [string]:      string | int | bool
#AnnotationsType: [string]: string | int | bool

// Common metadata for all OAM objects
#CommonObjectMeta: {
	#id:  #NameType
	name: #NameType | *#id
	...
}

// Base OAM object that all types extend
#Object: {
	#apiVersion:      string | *"core.oam.dev/v3alpha1"
	#kind:            string & strings.MinRunes(1) & strings.MaxRunes(254)
	#combinedVersion: string | "\(#apiVersion).\(#kind)"
	#metadata:        #CommonObjectMeta
	...
}

// Provider context passed to transformers
#ProviderContext: {
	namespace:  string | *"default"
	appName:    string
	appVersion: string
	appLabels: [string]: string
	componentName?: string
	componentId?:   string
	capabilities: [...string] // Provider capabilities
	config: {...} // Provider-specific config
}
