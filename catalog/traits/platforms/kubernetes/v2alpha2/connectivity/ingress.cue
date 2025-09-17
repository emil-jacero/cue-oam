package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Ingress defines the properties and behaviors of a Kubernetes Ingress
#Ingress: core.#Trait & {
	#metadata: #traits: Ingress: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/networking/v1"
		#kind:       "Ingress"
		description: "Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster"
		domain:      "connectivity"
		scope: ["component"]
		provides: {ingresses: [string]: schema.#IngressSpec}
	}
	ingresses: [string]: schema.#IngressSpec
}

#IngressMeta: #Ingress.#metadata.#traits.Ingress
