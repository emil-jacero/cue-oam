package standard

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Expose - Platform-agnostic port exposure trait
// Maps to Kubernetes Service or Docker Compose port publishing
#ExposeTraitMeta: core.#TraitObject & {
	#kind:       "Expose"
	description: "Platform-agnostic port exposure for services"
	type:        "atomic"
	category:    "structural"
	scope:       ["component"]
	requiredCapabilities: [
		"network.expose",
	]
	provides: {
		expose: {
			// Port mappings
			ports: [...{
				port!:       uint & >=1 & <=65535  // External/service port
				targetPort?: uint & >=1 & <=65535  // Container port (defaults to port)
				protocol?:   *"TCP" | "UDP"
				name?:       string
			}]
			
			// Exposure type
			// ClusterIP: Internal cluster access only (Kubernetes)
			// NodePort: Expose on node's port (Kubernetes)  
			// LoadBalancer: Cloud load balancer (Kubernetes)
			// HostPort: Direct host port mapping (Docker/Kubernetes)
			type?: *"ClusterIP" | "NodePort" | "LoadBalancer" | "HostPort"
			
			// For NodePort type (Kubernetes only)
			if type == "NodePort" {
				nodePort?: uint & >=30000 & <=32767
			}
			
			// For LoadBalancer type
			if type == "LoadBalancer" {
				loadBalancerIP?: string
				loadBalancerSourceRanges?: [...string]
			}
			
			// Selector labels for service discovery
			selector?: [string]: string
		}
	}
}
#Expose: core.#Trait & {
	#metadata: #traits: Expose: #ExposeTraitMeta

	expose: #ExposeTraitMeta.provides.expose
}

// Network Isolation Scope - manages network boundaries and policies
#NetworkIsolationScope: core.#Trait & {
	#metadata: #traits: NetworkIsolationScope: #NetworkIsolationScopeTraitMeta

	network: #NetworkIsolationScopeTraitMeta.provides.network
}
#NetworkIsolationScopeTraitMeta: core.#TraitMeta & {
	#kind:    "NetworkIsolationScope"
	type:     "atomic"
	category: "structural"
	scope: ["component", "scope"]
	requiredCapabilities: [
		"k8s.io/api/networking/v1.NetworkPolicy",
	]
	provides: {
		network: {
			isolation: "none" | "namespace" | "pod" | "strict" | *"namespace"
			policies?: [...{
				scope: "ingress" | "egress"
				from?: [...{
					namespaceSelector?: {...}
					podSelector?: {...}
					ipBlock?: {cidr: string}
				}]
				to?: [...{
					namespaceSelector?: {...}
					podSelector?: {...}
					ipBlock?: {cidr: string}
				}]
				ports?: [...{
					protocol: "TCP" | "UDP" | "SCTP"
					port:     int | string
				}]
			}]
		}
	}
}
