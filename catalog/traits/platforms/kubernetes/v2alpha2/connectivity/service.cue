package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Service defines the properties and behaviors of a Kubernetes Service
#Service: core.#Trait & {
	#metadata: #traits: Service: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/core/v1"
		#kind:       "Service"
		description: "Kubernetes Service for exposing an application running on a set of Pods as a network service"
		domain:      "connectivity"
		scope: ["component"]
		schema: {services: [string]: schema.#ServiceSpec}
	}
	services: [string]: schema.#ServiceSpec
}

#ServiceMeta: #Service.#metadata.#traits.Service
