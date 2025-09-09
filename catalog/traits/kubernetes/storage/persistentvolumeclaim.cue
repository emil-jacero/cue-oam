package storage

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

// PersistentVolumeClaimTrait defines the properties and behaviors of a Kubernetes PersistentVolumeClaim
#PersistentVolumeClaimTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "PersistentVolumeClaim"

	description: "Kubernetes PersistentVolumeClaim for requesting persistent storage"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.PersistentVolumeClaim",
	]

	provides: {
		persistentvolumeclaim: schema.PersistentVolumeClaim
	}
}
#PersistentVolumeClaim: core.#Trait & {
	#metadata: #traits: PersistentVolumeClaim: #PersistentVolumeClaimTrait
	persistentvolumeclaim: schema.PersistentVolumeClaim
}

// PersistentVolumeClaims defines the properties and behaviors of multiple Kubernetes PersistentVolumeClaims
#PersistentVolumeClaimsTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "PersistentVolumeClaims"

	description: "Kubernetes PersistentVolumeClaims for requesting persistent storage"

	type:   "atomic"
	domain: "resource"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/core/v1.PersistentVolumeClaim",
	]

	provides: {
		persistentvolumeclaims: [string]: schema.PersistentVolumeClaim
	}
}
#PersistentVolumeClaims: core.#Trait & {
	#metadata: #traits: PersistentVolumeClaims: #PersistentVolumeClaimsTrait
	persistentvolumeclaims: [string]: schema.PersistentVolumeClaim
}
