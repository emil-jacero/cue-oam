package networking

import (
	networkingv1 "cue.dev/x/k8s.io/api/networking/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// NetworkPolicy is a kubernetes networkpolicy resource with apiVersion and kind set to default values.
#NetworkPolicy: networkingv1.#NetworkPolicy & {
	apiVersion: "networking.k8s.io/v1"
	kind:       "NetworkPolicy"
	metadata:   metav1.#ObjectMeta
	spec?:      networkingv1.#NetworkPolicySpec
	status?:    networkingv1.#NetworkPolicyStatus
}

#NetworkPolicySpec: networkingv1.#NetworkPolicySpec

#NetworkPolicyStatus: networkingv1.#NetworkPolicyStatus
