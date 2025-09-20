package kubernetes

import (
	core "jacero.io/oam/core/v2alpha2"
	trait "jacero.io/oam/catalog/traits/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// Volume Transformer - Creates PersistentVolumeClaims
#VolumeTransformer: core.#Transformer & {
	accepts: "core.oam.dev/v2alpha2.Volume"
	transform: {
		input:   trait.#Volume
		context: core.#ProviderContext
		output: {
			let volumeSpec = input.volumes
			let meta = input.#metadata
			let ctx = context

			resources: [
				for volumeName, volume in volumeSpec
				if volume.type == "volume" {
					schema.#PersistentVolumeClaim & {
						metadata: #GenerateMetadata & {
							_input: {
								name:         "\(meta.name)-\(volumeName)"
								traitMeta:    meta
								context:      ctx
								resourceType: "persistent-volume-claim"
							}
						}
						spec: {
							if volume.accessModes != _|_ {
								accessModes: volume.accessModes
							}
							if volume.accessModes == _|_ {
								accessModes: ["ReadWriteOnce"]
							}
							resources: requests: storage: volume.size
							if volume.storageClassName != _|_ {
								storageClassName: volume.storageClassName
							}
						}
					}
				},
			]
		}
	}
}
