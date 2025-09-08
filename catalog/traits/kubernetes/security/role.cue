package security

import (
	core "jacero.io/oam/core/v2alpha2"
)

#Role: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Role"
	
	description: "Kubernetes Role contains rules that represent a set of permissions within a namespace"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.Role",
	]
	
	provides: {
		role: {
			// Role metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Rules holds all the PolicyRules for this Role
			rules: [...{
				// Verbs is a list of Verbs that apply to ALL the ResourceKinds contained in this rule
				verbs: [...("get" | "list" | "create" | "update" | "patch" | "watch" | "delete" | "deletecollection" | "*")]
				
				// APIGroups is the name of the APIGroup that contains the resources
				apiGroups?: [...string]
				
				// Resources is a list of resources this rule applies to
				resources?: [...string]
				
				// ResourceNames is an optional white list of names that the rule applies to
				resourceNames?: [...string]
				
				// NonResourceURLs is a set of partial urls that a user should have access to
				nonResourceURLs?: [...string]
			}]
		}
	}
}