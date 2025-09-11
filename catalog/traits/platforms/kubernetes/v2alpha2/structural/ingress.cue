package networking

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#IngressTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Ingress"

	description: "Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster"

	type:   "atomic"
	domain: "structural"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/networking/v1.Ingress",
	]

	provides: {
		ingress: schema.Ingress
	}
}
#Ingress: core.#Trait & {
	#metadata: #traits: Ingress: #IngressTrait
	ingress: schema.Ingress
}
