package configuration

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ConfigMap: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ConfigMap"
	
	description: "Kubernetes ConfigMap for storing configuration data as key-value pairs"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.ConfigMap",
	]
	
	provides: {
		configmap: {
			// ConfigMap metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Data contains the configuration data
			// Each key must consist of alphanumeric characters, '-', '_' or '.'
			data?: [string]: string
			
			// BinaryData contains the binary data
			// Each key must consist of alphanumeric characters, '-', '_' or '.'
			// The values in this field must be base64-encoded strings
			binaryData?: [string]: string
			
			// Immutable, if set to true, ensures that data stored in the ConfigMap cannot be updated
			immutable?: bool
		}
	}
}