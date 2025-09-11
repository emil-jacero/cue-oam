package observability

import (
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ServiceMonitor is a prometheus servicemonitor resource with apiVersion and kind set to default values.
// Note: ServiceMonitor is not part of core k8s.io schemas, so we define basic structure
#ServiceMonitor: {
	apiVersion: "monitoring.coreos.com/v1"
	kind:       "ServiceMonitor"
	metadata:   metav1.#ObjectMeta
	spec?:      #ServiceMonitorSpec
}

#ServiceMonitorSpec: {
	selector: metav1.#LabelSelector
	endpoints?: [...#Endpoint]
	jobLabel?: string
	targetLabels?: [...string]
	podTargetLabels?: [...string]
	sampleLimit?:           uint64
	targetLimit?:           uint64
	labelLimit?:            uint64
	labelNameLengthLimit?:  uint64
	labelValueLengthLimit?: uint64
	attachMetadata?: {
		node?: bool
	}
}

#Endpoint: {
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
	bearerTokenFile?:   string
	bearerTokenSecret?: #SecretKeySelector
	tlsConfig?:         #TLSConfig
	metricRelabelings?: [...#RelabelConfig]
	relabelings?: [...#RelabelConfig]
}

#BasicAuth: {
	username?: #SecretKeySelector
	password?: #SecretKeySelector
}

#SecretKeySelector: {
	name: string
	key:  string
}

#TLSConfig: {
	caFile?:             string
	ca?:                 #ConfigMapKeySelector | #SecretKeySelector
	certFile?:           string
	cert?:               #ConfigMapKeySelector | #SecretKeySelector
	keyFile?:            string
	keySecret?:          #SecretKeySelector
	serverName?:         string
	insecureSkipVerify?: bool
}

#ConfigMapKeySelector: {
	name: string
	key:  string
}

#RelabelConfig: {
	sourceLabels?: [...string]
	separator?:   string
	regex?:       string
	targetLabel?: string
	replacement?: string
	action?:      "replace" | "keep" | "drop" | "hashmod" | "labelmap" | "labeldrop" | "labelkeep"
}
