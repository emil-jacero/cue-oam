package configuration

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#ConfigMapsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ConfigMaps"

	description: "Kubernetes ConfigMaps for storing configuration data as key-value pairs"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.ConfigMap",
	]

	provides: {
		configmap: schema.ConfigMap
		configmaps: [string]: schema.ConfigMap
	}
}
#ConfigMaps: core.#Trait & {
	#metadata: #traits: ConfigMaps: #ConfigMapsTrait
	configmaps: [string]: schema.ConfigMap
}

#ConfigMapTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "ConfigMap"

	description: "Kubernetes ConfigMap for storing configuration data as key-value pairs"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.ConfigMap",
	]

	provides: {
		configmap: schema.ConfigMap
	}
}
#ConfigMap: core.#Trait & {
	#metadata: #traits: ConfigMaps: #ConfigMapsTrait
	configmap: schema.ConfigMap
}
