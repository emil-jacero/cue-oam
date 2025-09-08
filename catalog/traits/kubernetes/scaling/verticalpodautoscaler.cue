package scaling

import (
	core "jacero.io/oam/core/v2alpha2"
)

#VerticalPodAutoscaler: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "VerticalPodAutoscaler"
	
	description: "Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/autoscaling/v1.VerticalPodAutoscaler",
	]
	
	provides: {
		verticalpodautoscaler: {
			// VPA metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// VPA specification
			spec: {
				// TargetRef points to the controller managing the set of pods for the VPA to control
				targetRef: {
					apiVersion: string
					kind:       string
					name:       string
				}
				
				// UpdatePolicy controls how the autoscaler applies changes to the pod resources
				updatePolicy?: {
					// UpdateMode controls whether the VPA applies changes to the pod resources
					updateMode?: "Off" | "Initial" | "Recreate" | "Auto" | *"Auto"
				}
				
				// ResourcePolicy controls how the autoscaler computes recommended resources
				resourcePolicy?: {
					containerPolicies?: [...{
						// ContainerName is the name of the container or DefaultContainerResourcePolicy
						containerName?: string
						
						// Mode controls whether the VPA applies changes to this container
						mode?: "Off" | "Auto" | *"Auto"
						
						// MinAllowed specifies the minimal amount of resources that will be recommended
						minAllowed?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
						
						// MaxAllowed specifies the maximum amount of resources that will be recommended
						maxAllowed?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
						
						// ControlledResources specifies which resources are controlled by the autoscaler
						controlledResources?: [...("cpu" | "memory")]
						
						// ControlledValues specifies which resource values should be controlled
						controlledValues?: "RequestsAndLimits" | "RequestsOnly" | *"RequestsAndLimits"
					}]
				}
			}
			
			// VPA status
			status?: {
				// LastUpdateTime is the last time the status was updated
				lastUpdateTime?: string
				
				// Recommendation holds the recommended resources for the container
				recommendation?: {
					containerRecommendations?: [...{
						containerName?: string
						target?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
						lowerBound?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
						upperBound?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
						uncappedTarget?: {
							cpu?:    string
							memory?: string
							[string]: string
						}
					}]
				}
				
				// Conditions is the set of conditions required for this autoscaler to scale its target
				conditions?: [...{
					type:               "RecommendationProvided" | "LowConfidence" | "NoPodsMatched" | "FetchingHistory" | "ConfigDeprecated" | "ConfigUnsupported"
					status:             "True" | "False" | "Unknown"
					lastTransitionTime: string
					reason?:            string
					message?:           string
				}]
			}
		}
	}
}