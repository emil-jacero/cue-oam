package data

import (
	// "strings"
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Volume trait definition
// Describes a set of volumes
#VolumeMeta: #Volume.#metadata.#traits.Volume

#Volume: core.#Trait & {
	#metadata: #traits: Volume: core.#TraitMetaAtomic & {
		#kind:       "Volume"
		description: "Describes a set of volumes to be used by containers"
		domain:      "data"
		scope: ["component"]
		schema: volumes: [string]: schema.#VolumeSpec
	}

	// Volumes to be created
	volumes: [string]: schema.#VolumeSpec
	// volumes: [string]: schema.#VolumeSpec & {
	// 	// The type of the storage volume.
	// 	type!: schema.#PersistenceTypes

	// 	// emptyDir represents a temporary directory that shares a pod's lifetime.
	// 	if type == "emptyDir" {
	// 		// medium specifies the medium type of the emptyDir volume.
	// 		// If not specified, defaults to "" (disk).
	// 		// Valid values are "Memory" for memory-backed volumes.
	// 		medium?: string & "Memory"
	// 		// sizeLimit specifies the maximum size of the emptyDir volume.
	// 		// If not specified, defaults to "" (no limit).
	// 		sizeLimit?: string & schema.#StorageQuantity
	// 	}

	// 	// config represents a ConfigMap that should populate this volume.
	// 	if type == "configMap" {
	// 		// config is the ConfigMap to treat as a volume.
	// 		config!: schema.#ConfigSpec
	// 	}

	// 	// secret represents a Secret that should populate this volume.
	// 	if type == "secret" {
	// 		// secret is the secret to treat as a volume.
	// 		secret!: schema.#SecretSpec
	// 	}

	// 	// hostPath represents a pre-existing file or directory on the host machine that is directly exposed to the container.
	// 	if type == "hostPath" {
	// 		// Path of the directory on the host.
	// 		hostPath!: string & strings.MaxRunes(1024)
	// 		// Type of the hostPath volume.
	// 		// Valid values are "Directory", "File", "Socket", "CharDevice", "BlockDevice", "DirectoryOrCreate", "FileOrCreate".
	// 		// If not specified, defaults to "".
	// 		hostPathType: schema.#HostPathType
	// 	}

	// 	// volume represents a persistent volume that should populate this volume.
	// 	// This is mostly used for Kubernetes workloads but does represent a persistent volume in Docker Compose as well.
	// 	if type == "volume" {schema.#PersistentVolumeSpec}
	// }
}
