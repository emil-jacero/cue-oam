package networking

import (
	core "jacero.io/oam/core/v2alpha2"
)

#Service: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Service"
	
	description: "Kubernetes Service for exposing an application running on a set of Pods as a network service"
	
	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.Service",
	]
	
	provides: {
		service: {
			// Service metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Service specification
			spec: {
				// Selector to select pods
				selector?: [string]: string
				
				// The list of ports that are exposed by this service
				ports?: [...{
					// The name of this port within the service
					name?: string
					
					// The IP protocol for this port
					protocol?: "TCP" | "UDP" | "SCTP" | *"TCP"
					
					// The application protocol for this port
					appProtocol?: string
					
					// The port that will be exposed by this service
					port: int32 & >=1 & <=65535
					
					// Number or name of the port to access on the pods targeted by the service
					targetPort?: int32 | string
					
					// The port on each node on which this service is exposed when type=NodePort or LoadBalancer
					nodePort?: int32 & >=30000 & <=32767
				}]
				
				// ClusterIP is the IP address of the service
				clusterIP?: string | "None"
				
				// ClusterIPs is a list of IP addresses assigned to this service
				clusterIPs?: [...string]
				
				// Type determines how the Service is exposed
				type?: "ClusterIP" | "NodePort" | "LoadBalancer" | "ExternalName" | *"ClusterIP"
				
				// externalIPs is a list of IP addresses for which nodes will also accept traffic
				externalIPs?: [...string]
				
				// Supports "ClientIP" and "None"
				sessionAffinity?: "ClientIP" | "None" | *"None"
				
				// LoadBalancerIP is the IP address of the load balancer
				loadBalancerIP?: string
				
				// LoadBalancerSourceRanges restrict traffic through the cloud-provider load-balancer
				loadBalancerSourceRanges?: [...string]
				
				// ExternalName is the external reference that kubedns or equivalent will return
				externalName?: string
				
				// ExternalTrafficPolicy denotes if this Service desires to route external traffic to node-local endpoints only
				externalTrafficPolicy?: "Cluster" | "Local"
				
				// HealthCheckNodePort specifies the healthcheck nodePort for the service
				healthCheckNodePort?: int32
				
				// PublishNotReadyAddresses indicates that the service controller should not use ready endpoints
				publishNotReadyAddresses?: bool
				
				// SessionAffinityConfig contains the configurations of session affinity
				sessionAffinityConfig?: {
					clientIP?: {
						timeoutSeconds?: int32
					}
				}
				
				// TopologyKeys is a preference-order list of topology keys
				topologyKeys?: [...string] | *null
				
				// IPFamilies is a list of IP families (e.g. IPv4, IPv6) assigned to this service
				ipFamilies?: [...("IPv4" | "IPv6")]
				
				// IPFamilyPolicy represents the dual-stack-ness requested or required by this Service
				ipFamilyPolicy?: "SingleStack" | "PreferDualStack" | "RequireDualStack"
				
				// AllocateLoadBalancerNodePorts defines if NodePorts will be automatically allocated for services with type LoadBalancer
				allocateLoadBalancerNodePorts?: bool
				
				// LoadBalancerClass is the class of the load balancer implementation this Service belongs to
				loadBalancerClass?: string
				
				// InternalTrafficPolicy specifies if the cluster internal traffic should be routed to all endpoints or node-local endpoints only
				internalTrafficPolicy?: "Cluster" | "Local"
			}
		}
	}
}