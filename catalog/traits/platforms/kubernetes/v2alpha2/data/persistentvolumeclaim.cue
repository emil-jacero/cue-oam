package data

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// PersistentVolumeClaim defines the properties and behaviors of a Kubernetes PersistentVolumeClaim
#PersistentVolumeClaim: core.#Trait & {
	#metadata: #traits: PersistentVolumeClaim: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/core/v1"
		#kind:       "PersistentVolumeClaim"
		description: "Kubernetes PersistentVolumeClaim for requesting persistent storage"
		domain:      "data"
		scope: ["component"]
		schema: {persistentvolumeclaims: [string]: schema.#PersistentVolumeClaimSpec}
	}
	persistentvolumeclaims: [string]: schema.#PersistentVolumeClaimSpec
}

#PersistentVolumeClaimMeta: #PersistentVolumeClaim.#metadata.#traits.PersistentVolumeClaim
