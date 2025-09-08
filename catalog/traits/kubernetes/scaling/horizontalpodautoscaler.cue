package scaling

import (
	core "jacero.io/oam/core/v2alpha2"
)

#HorizontalPodAutoscaler: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "HorizontalPodAutoscaler"
	
	description: "Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/autoscaling/v2.HorizontalPodAutoscaler",
	]
	
	provides: {
		horizontalpodautoscaler: {
			// HPA metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// HPA specification
			spec: {
				// Reference to scaled resource
				scaleTargetRef: {
					apiVersion: string
					kind:       string
					name:       string
				}
				
				// Lower limit for the number of pods
				minReplicas?: int32 & >=1 | *1
				
				// Upper limit for the number of pods
				maxReplicas: int32 & >=1
				
				// Metrics contains the specifications for which to use to calculate the desired replica count
				metrics?: [...{
					type: "Object" | "Pods" | "Resource" | "ContainerResource" | "External"
					
					// Object metric (if type is "Object")
					object?: {
						metric: {
							name: string
							selector?: {
								matchLabels?: [string]: string
								matchExpressions?: [...{
									key:      string
									operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
									values?: [...string]
								}]
							}
						}
						target: {
							type: "Value" | "AverageValue" | "Utilization"
							value?: string
							averageValue?: string
							averageUtilization?: int32
						}
						describedObject: {
							apiVersion: string
							kind:       string
							name:       string
						}
					}
					
					// Pods metric (if type is "Pods")
					pods?: {
						metric: {
							name: string
							selector?: {
								matchLabels?: [string]: string
								matchExpressions?: [...{
									key:      string
									operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
									values?: [...string]
								}]
							}
						}
						target: {
							type: "Value" | "AverageValue" | "Utilization"
							value?: string
							averageValue?: string
							averageUtilization?: int32
						}
					}
					
					// Resource metric (if type is "Resource")
					resource?: {
						name: "cpu" | "memory" | string
						target: {
							type: "Value" | "AverageValue" | "Utilization"
							value?: string
							averageValue?: string
							averageUtilization?: int32
						}
					}
					
					// ContainerResource metric (if type is "ContainerResource")
					containerResource?: {
						name: "cpu" | "memory" | string
						container: string
						target: {
							type: "Value" | "AverageValue" | "Utilization"
							value?: string
							averageValue?: string
							averageUtilization?: int32
						}
					}
					
					// External metric (if type is "External")
					external?: {
						metric: {
							name: string
							selector?: {
								matchLabels?: [string]: string
								matchExpressions?: [...{
									key:      string
									operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
									values?: [...string]
								}]
							}
						}
						target: {
							type: "Value" | "AverageValue" | "Utilization"
							value?: string
							averageValue?: string
							averageUtilization?: int32
						}
					}
				}]
				
				// Behavior configures the scaling behavior of the target
				behavior?: {
					scaleUp?: {
						stabilizationWindowSeconds?: int32
						policies?: [...{
							type:          "Percent" | "Pods"
							value:         int32
							periodSeconds: int32
						}]
						selectPolicy?: "Max" | "Min" | "Disabled"
					}
					scaleDown?: {
						stabilizationWindowSeconds?: int32
						policies?: [...{
							type:          "Percent" | "Pods"
							value:         int32
							periodSeconds: int32
						}]
						selectPolicy?: "Max" | "Min" | "Disabled"
					}
				}
			}
			
			// HPA status
			status?: {
				observedGeneration?: int64
				lastScaleTime?: string
				currentReplicas: int32
				desiredReplicas: int32
				currentMetrics?: [...{
					type: "Object" | "Pods" | "Resource" | "ContainerResource" | "External"
					// ... (similar structure to spec.metrics)
				}]
				conditions?: [...{
					type:               "AbleToScale" | "ScalingActive" | "ScalingLimited"
					status:             "True" | "False" | "Unknown"
					lastTransitionTime: string
					reason?:            string
					message?:           string
				}]
			}
		}
	}
}