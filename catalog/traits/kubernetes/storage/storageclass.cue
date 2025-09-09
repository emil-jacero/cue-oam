package storage

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// StorageClassTrait defines the properties and behaviors of a Kubernetes StorageClass
#StorageClassTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "StorageClass"
	
	description: "Kubernetes StorageClass for defining classes of storage"
	
	type:     "atomic"
	domain: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/storage/v1.StorageClass",
	]
	
	provides: {
		storageclass: schema.StorageClass
	}
}
#StorageClass: core.#Trait & {
	#metadata: #traits: StorageClass: #StorageClassTrait
	storageclass: schema.StorageClass
}
