package observability

import (
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// PodMonitor is a prometheus podmonitor resource with apiVersion and kind set to default values.
// Note: PodMonitor is not part of core k8s.io schemas, so we define basic structure
#PodMonitor: {
	apiVersion: "monitoring.coreos.com/v1"
	kind:       "PodMonitor"
	metadata:   metav1.#ObjectMeta
	spec?:      #PodMonitorSpec
}

#PodMonitorSpec: {
	selector: metav1.#LabelSelector
	podMetricsEndpoints: [...#PodMetricsEndpoint]
	jobLabel?: string
	podTargetLabels?: [...string]
	sampleLimit?:           uint64
	targetLimit?:           uint64
	labelLimit?:            uint64
	labelNameLengthLimit?:  uint64
	labelValueLengthLimit?: uint64
	attachMetadata?: {
		node?: bool
	}
	namespaceSelector?: {
		any?: bool
		matchNames?: [...string]
	}
}

#PodMetricsEndpoint: {
	port?:       string
	targetPort?: int | string
	path?:       string
	scheme?:     "http" | "https"
	params?: [string]: [...string]
	interval?:          string
	scrapeTimeout?:     string
	proxyUrl?:          string
	followRedirects?:   bool
	enableHttp2?:       bool
	honorLabels?:       bool
	honorTimestamps?:   bool
	basicAuth?:         #BasicAuth
	bearerTokenSecret?: #SecretKeySelector
	tlsConfig?:         #TLSConfig
	metricRelabelings?: [...#RelabelConfig]
	relabelings?: [...#RelabelConfig]
}
