package configuration

import (
	core "jacero.io/oam/core/v2alpha2"
)

#Secret: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Secret"
	
	description: "Kubernetes Secret for storing sensitive configuration data"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.Secret",
	]
	
	provides: {
		secret: {
			// Secret metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Type of secret
			type?: "Opaque" | "kubernetes.io/service-account-token" | "kubernetes.io/dockercfg" | "kubernetes.io/dockerconfigjson" | "kubernetes.io/basic-auth" | "kubernetes.io/ssh-auth" | "kubernetes.io/tls" | "bootstrap.kubernetes.io/token" | *"Opaque"
			
			// Data contains the secret data
			// Each key must consist of alphanumeric characters, '-', '_' or '.'
			// The values in this field must be base64-encoded strings
			data?: [string]: string
			
			// StringData allows specifying non-binary secret data in string form
			// It is provided as a write-only convenience method
			stringData?: [string]: string
			
			// Immutable, if set to true, ensures that data stored in the Secret cannot be updated
			immutable?: bool
		}
	}
}