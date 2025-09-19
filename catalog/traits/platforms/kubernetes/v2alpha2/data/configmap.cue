package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// ConfigMap defines the properties and behaviors of a Kubernetes ConfigMap
#ConfigMap: core.#Trait & {
	#metadata: #traits: ConfigMap: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/core/v1"
		#kind:       "ConfigMap"
		description: "Kubernetes ConfigMap for storing configuration data as key-value pairs"
		domain:      "data"
		scope: ["component"]
		schema: {configmaps: [string]: schema.#ConfigMapSpec}
	}
	configmaps: [string]: schema.#ConfigMapSpec
}

#ConfigMapMeta: #ConfigMap.#metadata.#traits.ConfigMap
