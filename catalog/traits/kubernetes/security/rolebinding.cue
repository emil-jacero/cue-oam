package security

import (
	core "jacero.io/oam/core/v2alpha2"
)

#RoleBinding: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "RoleBinding"
	
	description: "Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.RoleBinding",
	]
	
	provides: {
		rolebinding: {
			// RoleBinding metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Subjects holds references to the objects the role applies to
			subjects?: [...{
				// Kind of object being referenced
				kind: "User" | "Group" | "ServiceAccount"
				
				// Name of the object being referenced
				name: string
				
				// APIGroup holds the API group of the referenced subject
				apiGroup?: string
				
				// Namespace of the referenced object
				namespace?: string
			}]
			
			// RoleRef can reference a Role in the current namespace or a ClusterRole in the global namespace
			roleRef: {
				// APIGroup is the group for the resource being referenced
				apiGroup: "rbac.authorization.k8s.io"
				
				// Kind is the type of resource being referenced
				kind: "Role" | "ClusterRole"
				
				// Name is the name of resource being referenced
				name: string
			}
		}
	}
}