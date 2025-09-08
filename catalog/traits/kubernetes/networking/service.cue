package networking

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// ServicesTrait defines the properties and behaviors of Kubernetes Services
#ServicesTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Services"

	description: "Kubernetes Services for exposing an application running on a set of Pods as a network service"

	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.Service",
	]
	
	provides: {
		services: [string]: schema.Service
	}
}
#Services: core.#Trait & {
	#metadata: #traits: Services: #ServicesTrait
	services: [string]: schema.Service
}

// ServiceTrait defines the properties and behaviors of a Kubernetes Service
#ServiceTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Service"

	description: "Kubernetes Service for exposing an application running on a set of Pods as a network service"

	type:     "atomic"
	category: "structural"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.Service",
	]
	
	provides: {
		service: schema.Service
	}
}
#Service: core.#Trait & {
	#metadata: #traits: Services: #ServicesTrait
	service: schema.Service
}
