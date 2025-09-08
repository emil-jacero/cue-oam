package observability

import (
	core "jacero.io/oam/core/v2alpha2"
)

#ServiceMonitor: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ServiceMonitor"
	
	description: "Prometheus ServiceMonitor for scraping metrics from services"
	
	type:     "atomic"
	category: "operational"
	scope: ["component"]
	
	requiredCapabilities: [
		"monitoring.coreos.com/v1.ServiceMonitor",
	]
	
	provides: {
		servicemonitor: {
			// ServiceMonitor metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// ServiceMonitor specification
			spec: {
				// Selector to select Endpoints objects
				selector: {
					matchLabels?: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}
				
				// Endpoints defines the collection of endpoints to scrape metrics from
				endpoints?: [...{
					// Port the metrics endpoint is available on
					port?: string
					
					// TargetPort allows specifying the targetPort that scrape requests will be sent to
					targetPort?: int32 | string
					
					// Path to scrape metrics from
					path?: string | *"/metrics"
					
					// Scheme allows specifying the protocol scheme to use for scraping
					scheme?: "http" | "https" | *"http"
					
					// Params specify the query parameters to add to the scrape request
					params?: [string]: [...string]
					
					// Interval at which metrics should be scraped
					interval?: string | *"30s"
					
					// ScrapeTimeout is the timeout after which the scrape is ended
					scrapeTimeout?: string
					
					// Optional HTTP path to probe for health-checking
					proxyUrl?: string
					
					// FollowRedirects configures whether scrape requests follow HTTP 3xx redirects
					followRedirects?: bool
					
					// EnableHttp2 whether to use HTTP2 over HTTPS
					enableHttp2?: bool
					
					// HonorLabels chooses the metric's labels on collisions with target labels
					honorLabels?: bool
					
					// HonorTimestamps controls whether Prometheus respects the timestamps present in scraped data
					honorTimestamps?: bool
					
					// BasicAuth allow an endpoint to authenticate over basic authentication
					basicAuth?: {
						username?: {
							name: string
							key:  string
						}
						password?: {
							name: string
							key:  string
						}
					}
					
					// BearerTokenFile specifies a key of a Secret containing the bearer token
					bearerTokenFile?: string
					
					// BearerTokenSecret specifies a key of a Secret containing the bearer token
					bearerTokenSecret?: {
						name: string
						key:  string
					}
					
					// TLSConfig specifies TLS configuration parameters
					tlsConfig?: {
						caFile?: string
						ca?: {
							configMap?: {
								name: string
								key:  string
							}
							secret?: {
								name: string
								key:  string
							}
						}
						certFile?: string
						cert?: {
							configMap?: {
								name: string
								key:  string
							}
							secret?: {
								name: string
								key:  string
							}
						}
						keyFile?: string
						keySecret?: {
							name: string
							key:  string
						}
						serverName?: string
						insecureSkipVerify?: bool
					}
					
					// MetricRelabelConfigs to apply to samples before ingestion
					metricRelabelings?: [...{
						sourceLabels?: [...string]
						separator?: string
						regex?: string
						targetLabel?: string
						replacement?: string
						action?: "replace" | "keep" | "drop" | "hashmod" | "labelmap" | "labeldrop" | "labelkeep"
					}]
					
					// RelabelConfigs to apply to samples before scraping
					relabelings?: [...{
						sourceLabels?: [...string]
						separator?: string
						regex?: string
						targetLabel?: string
						replacement?: string
						action?: "replace" | "keep" | "drop" | "hashmod" | "labelmap" | "labeldrop" | "labelkeep"
					}]
				}]
				
				// JobLabel selects the label from the associated Kubernetes service which will be used as the job label
				jobLabel?: string
				
				// TargetLabels transfers the labels on the Kubernetes service onto the target
				targetLabels?: [...string]
				
				// PodTargetLabels transfers the labels on the Kubernetes Pod onto the target
				podTargetLabels?: [...string]
				
				// SampleLimit defines per-scrape limit on number of scraped samples that will be accepted
				sampleLimit?: uint64
				
				// TargetLimit defines a limit on the number of scraped targets that will be accepted
				targetLimit?: uint64
				
				// LabelLimit defines a limit on the number of labels that will be accepted for a sample
				labelLimit?: uint64
				
				// LabelNameLengthLimit defines a limit on the length of labels name that will be accepted for a sample
				labelNameLengthLimit?: uint64
				
				// LabelValueLengthLimit defines a limit on the length of labels value that will be accepted for a sample
				labelValueLengthLimit?: uint64
				
				// AttachMetadata configures metadata which is attached to the discovered targets
				attachMetadata?: {
					node?: bool
				}
			}
		}
	}
}