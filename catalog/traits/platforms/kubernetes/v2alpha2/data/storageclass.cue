package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// StorageClass defines the properties and behaviors of a Kubernetes StorageClass
#StorageClass: core.#Trait & {
	#metadata: #traits: StorageClass: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/storage/v1"
		#kind:       "StorageClass"
		description: "Kubernetes StorageClass for defining classes of storage"
		domain:      "data"
		scope: ["component"]
		provides: {storageclass: schema.#StorageClassSpec}
	}
	storageclass: schema.#StorageClassSpec
}

#StorageClassMeta: #StorageClass.#metadata.#traits.StorageClass
