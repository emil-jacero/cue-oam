package networking

import (
	core "jacero.io/oam/core/v2alpha2"
)

#Ingress: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Ingress"
	
	description: "Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster"
	
	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/networking/v1.Ingress",
	]
	
	provides: {
		ingress: {
			// Ingress metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Ingress specification
			spec: {
				// IngressClassName is the name of the IngressClass cluster resource
				ingressClassName?: string
				
				// DefaultBackend is the backend that should handle requests that don't match any rule
				defaultBackend?: {
					service?: {
						name: string
						port?: {
							name?:   string
							number?: int32 & >=1 & <=65535
						}
					}
					resource?: {
						apiGroup: string
						kind:     string
						name:     string
					}
				}
				
				// TLS configuration
				tls?: [...{
					// Hosts are a list of hosts included in the TLS certificate
					hosts?: [...string]
					
					// SecretName is the name of the secret used to terminate TLS traffic
					secretName?: string
				}]
				
				// Rules is a list of host rules used to configure the Ingress
				rules?: [...{
					// Host is the fully qualified domain name of a network host
					host?: string
					
					// HTTP contains the HTTP routing rules for this host
					http?: {
						paths: [...{
							// Path is matched against the path of an incoming request
							path?: string
							
							// PathType determines the interpretation of the path matching
							pathType: "Exact" | "Prefix" | "ImplementationSpecific"
							
							// Backend defines the referenced service endpoint
							backend: {
								service?: {
									name: string
									port?: {
										name?:   string
										number?: int32 & >=1 & <=65535
									}
								}
								resource?: {
									apiGroup: string
									kind:     string
									name:     string
								}
							}
						}]
					}
				}]
			}
			
			// Ingress status
			status?: {
				// LoadBalancer contains the current status of the load-balancer
				loadBalancer?: {
					ingress?: [...{
						ip?:       string
						hostname?: string
						ports?: [...{
							port:     int32
							protocol: "TCP" | "UDP"
							error?:   string
						}]
					}]
				}
			}
		}
	}
}