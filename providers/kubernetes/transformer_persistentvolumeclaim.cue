package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// PersistentVolumeClaim Transformer - Creates Kubernetes PersistentVolumeClaim resources
#PersistentVolumeClaimTransformer: core.#Transformer & {
	creates: "k8s.io/api/core/v1.PersistentVolumeClaim"

	required: [
		"core.oam.dev/v2alpha2.Volume",
	]

	optional: []

	// Default values for various traits.
	// These are automatically included for optional traits if not specified in the component.
	defaults: {...} // see #Transformer interface

	registry: trait.#TraitRegistry

	validates: {
		// This transformer only processes components that have persistent volumes
		// We don't validate a specific deployment type since PVCs are used by many types
	}

	transform: {
		component: core.#Component
		context:   core.#ProviderContext

		// Extract traits with CUE defaults
		let _volumes = component.volumes

		output: [
			for volumeName, volume in _volumes {
				if volume.type == "volume" {
					schema.#PersistentVolumeClaim & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(component.#metadata.name)-\(volumeName)"
								traitMeta:    component.#metadata
								context:      context
								resourceType: "persistentvolumeclaim"
							}
						}
						spec: {
							accessModes: volume.accessModes | *["ReadWriteOnce"]
							resources: requests: storage: volume.size
							
							if volume.storageClassName != _|_ {
								storageClassName: volume.storageClassName
							}
							
							if volume.volumeMode != _|_ {
								volumeMode: volume.volumeMode
							}
						}
					}
				}
			},
		]
	}
}