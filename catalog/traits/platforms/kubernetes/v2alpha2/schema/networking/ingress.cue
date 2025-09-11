package networking

import (
	networkingv1 "cue.dev/x/k8s.io/api/networking/v1"
	metav1 "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Ingress is a kubernetes ingress resource with apiVersion and kind set to default values.
#Ingress: networkingv1.#Ingress & {
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata:   metav1.#ObjectMeta
	spec?:      networkingv1.#IngressSpec
	status?:    networkingv1.#IngressStatus
}

#IngressSpec: networkingv1.#IngressSpec

#IngressStatus: networkingv1.#IngressStatus
