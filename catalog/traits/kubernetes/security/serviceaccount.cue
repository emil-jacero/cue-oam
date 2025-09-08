package security

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ServiceAccount: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ServiceAccount"
	
	description: "Kubernetes ServiceAccount provides an identity for processes that run in a Pod"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.ServiceAccount",
	]
	
	provides: {
		serviceaccount: {
			// ServiceAccount metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Secrets is a list of the secrets in the same namespace that pods using this ServiceAccount are allowed to use
			secrets?: [...{
				apiVersion?: string
				fieldPath?:  string
				kind?:       string
				name?:       string
				namespace?:  string
				resourceVersion?: string
				uid?:        string
			}]
			
			// ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling images
			imagePullSecrets?: [...{
				name?: string
			}]
			
			// AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted
			automountServiceAccountToken?: bool
		}
	}
}