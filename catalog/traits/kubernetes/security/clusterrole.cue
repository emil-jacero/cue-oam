package security

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ClusterRole: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ClusterRole"
	
	description: "Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/rbac/v1.ClusterRole",
	]
	
	provides: {
		clusterrole: {
			// ClusterRole metadata (no namespace)
			metadata: {
				name: string
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Rules holds all the PolicyRules for this ClusterRole
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
			
			// AggregationRule is an optional field that describes how to build the Rules for this ClusterRole
			aggregationRule?: {
				clusterRoleSelectors?: [...{
					matchLabels?: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}]
			}
		}
	}
}