package networking

import (
	core "jacero.io/oam/core/v2alpha2"
)

#NetworkPolicy: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "NetworkPolicy"
	
	description: "Kubernetes NetworkPolicy for controlling network traffic to and from pods"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/networking/v1.NetworkPolicy",
	]
	
	provides: {
		networkpolicy: {
			// NetworkPolicy metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// NetworkPolicy specification
			spec: {
				// Selects the pods to which this NetworkPolicy object applies
				podSelector: {
					matchLabels?: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}
				
				// List of ingress rules to be applied to the selected pods
				ingress?: [...{
					// List of ports which should be made accessible on the pods selected for this rule
					ports?: [...{
						// Protocol is the protocol which traffic must match
						protocol?: "TCP" | "UDP" | "SCTP"
						
						// Port is the port on the given protocol
						port?: int32 | string
						
						// EndPort indicates that the range of ports spans from port to endPort
						endPort?: int32
					}]
					
					// List of sources which should be able to access the pods selected for this rule
					from?: [...{
						// PodSelector selects Pods in the same namespace as the NetworkPolicy
						podSelector?: {
							matchLabels?: [string]: string
							matchExpressions?: [...{
								key:      string
								operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
								values?: [...string]
							}]
						}
						
						// NamespaceSelector selects Namespaces using cluster-scoped labels
						namespaceSelector?: {
							matchLabels?: [string]: string
							matchExpressions?: [...{
								key:      string
								operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
								values?: [...string]
							}]
						}
						
						// IPBlock describes a particular CIDR
						ipBlock?: {
							// CIDR is a string representing the IP Block
							cidr: string
							
							// Except is a slice of CIDRs that should not be included within an IP Block
							except?: [...string]
						}
					}]
				}]
				
				// List of egress rules to be applied to the selected pods
				egress?: [...{
					// List of destination ports for outgoing traffic
					ports?: [...{
						// Protocol is the protocol which traffic must match
						protocol?: "TCP" | "UDP" | "SCTP"
						
						// Port is the port on the given protocol
						port?: int32 | string
						
						// EndPort indicates that the range of ports spans from port to endPort
						endPort?: int32
					}]
					
					// List of destinations for outgoing traffic of pods selected for this rule
					to?: [...{
						// PodSelector selects Pods in the same namespace as the NetworkPolicy
						podSelector?: {
							matchLabels?: [string]: string
							matchExpressions?: [...{
								key:      string
								operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
								values?: [...string]
							}]
						}
						
						// NamespaceSelector selects Namespaces using cluster-scoped labels
						namespaceSelector?: {
							matchLabels?: [string]: string
							matchExpressions?: [...{
								key:      string
								operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
								values?: [...string]
							}]
						}
						
						// IPBlock describes a particular CIDR
						ipBlock?: {
							// CIDR is a string representing the IP Block
							cidr: string
							
							// Except is a slice of CIDRs that should not be included within an IP Block
							except?: [...string]
						}
					}]
				}]
				
				// List of rule types that the NetworkPolicy relates to
				policyTypes?: [...("Ingress" | "Egress")]
			}
		}
	}
}