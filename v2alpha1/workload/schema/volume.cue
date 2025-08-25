package schema

import (
	"strings"

	v2alpha1core "jacero.io/oam/v2alpha1/core"
)

#Storage: {
	v2alpha1core.#Object

	metadata: name:       _
	metadata: namespace?: _

	spec: #VolumeSpec & {
		type: #PersistenceTypes
		if type == "volume" {
			// The name of the PersistentVolume.
			// Auto-generated if not specified.
			if metadata.name != "" & metadata.namespace != "" {
				name: string | *"\(metadata.namespace)-\(metadata.name)-volume"
			}
			if metadata.name != "" & metadata.namespace == "" {
				name: string | *"\(metadata.name)-volume"
			}
		}
	}
}

// Volume is a modified version of VolumeSpec adds name to the volume specification.
// It is a generalized specification to help unify platforms like Kubernetes and Docker Compose.
#Volume: #VolumeSpec & {
	// The name of the storage volume.
	name: string & strings.MaxRunes(254)
}

// VolumeSpec defines the schema for a volume in a workload.
// It is a generalized specification to help unify platforms like Kubernetes and Docker Compose.
// It includes various types of volumes, such as emptyDir, configMap, secret, hostPath, and persistent volumes.
// TODO: Finalize Secret
// TODO: Finalize ConfigMap
#VolumeSpec: {
	// The type of the storage volume.
	type: #PersistenceTypes

	// The actual mount path in the filesystem.
	// Sets the target directory in the container where the volume will be mounted.
	mountPath: string

	// Path within the volume from which the container's volume should be mounted. Defaults to "" (volume's root).
	// Specifies which subdirectory or file within the volume should be mounted at the mountPath.
	subPath?: string & strings.MaxRunes(1024)

	// Canonical per-mount access (Compose ro/rw -> K8s volumeMount.readOnly)
	readOnly?: bool | *false

	// mountOptions is the list of mount options, e.g. ["ro", "soft"]. Not validated - mount will
	// simply fail if one is invalid.
	mountOptions?: [...string]

	volumeMountOptions?: {
		// mountPropagation determines how mounts are propagated from the host
		// to container and the other way around.
		// When not set, MountPropagationNone is used.
		// This field is beta in 1.10.
		// When RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified
		// (which defaults to None).
		mountPropagation?: *"None" | "HostToContainer" | "Bidirectional"
		// Expanded path within the volume from which the container's volume should be mounted.
		// Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.
		// Defaults to "" (volume's root).
		// SubPathExpr and SubPath are mutually exclusive.
		subPathExpr?: string & strings.MaxRunes(1024)
	}

	// emptyDir represents a temporary directory that shares a pod's lifetime.
	if type == "emptyDir" {
		// medium specifies the medium type of the emptyDir volume.
		// If not specified, defaults to "" (disk).
		// Valid values are "Memory" for memory-backed volumes.
		medium?: string & "Memory"
		// sizeLimit specifies the maximum size of the emptyDir volume.
		// If not specified, defaults to "" (no limit).
		sizeLimit?: string & #StorageQuantity
	}

	// configMap represents a ConfigMap that should populate this volume.
	if type == "configMap" {
		// Items to map from the ConfigMap.
		items?: [...#KeyToPath]
		// Mode bits to use on this volume, must be a value between 0000 and 0777.
		defaultMode?: int & >=0o000 & <=0o777
		// Optional specify whether the ConfigMap or its keys must be defined
		optional?: bool
	}

	// secret represents a Secret that should populate this volume.
	if type == "secret" {
		// secretName of the secret in the same namespace as the pod.
		secretName: string & strings.MaxRunes(256)
		// Items to map from the Secret.
		items?: [...#KeyToPath]
		// Mode bits to use on this volume, must be a value between 0000 and 0777.
		defaultMode?: int & >=0o000 & <=0o777
		// Optional specify whether the ConfigMap or its keys must be defined
		optional?: bool
	}

	// hostPath represents a pre-existing file or directory on the host machine that is directly exposed to the container.
	if type == "hostPath" {
		// Path of the directory on the host.
		hostPath: string & strings.MaxRunes(1024)
		// Type of the hostPath volume.
		// Valid values are "Directory", "File", "Socket", "CharDevice", "BlockDevice", "DirectoryOrCreate", "FileOrCreate".
		// If not specified, defaults to "".
		hostPathType: #HostPathType
	}

	// volume represents a persistent volume that should populate this volume.
	// This is mostly used for Kubernetes workloads but does represent a persistent volume in Docker Compose as well.
	if type == "volume" {#PersistentVolumeSpec}
	...
}

#PersistentVolumeSpec: {
	// The name of the PersistentVolume.
	name: string & strings.MaxRunes(256)
	// The size of the volume, e.g. "1Gi".
	// Converted for docker compose to "1G" or "1GiB".
	size: string & #StorageQuantity
	// The access modes for the PersistentVolume.
	// Valid values are "ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany", "ReadWriteOncePod".
	// If not specified, defaults to ["ReadWriteOnce"].
	// ignored by Docker Compose.
	accessModes: #AccessModes
	// The storage class to use for the PersistentVolume.
	// If not specified, defaults to "standard" for Kubernetes.
	// Ignored by Docker Compose.
	storageClassName?: string & strings.MaxRunes(256)
	// The volume mode for the PersistentVolume.
	// Valid values are "Filesystem" or "Block". Defaults to "Filesystem".
	// Ignored by Docker Compose.
	volumeMode?: #VolumeMode
	// The reclaim policy for the PersistentVolume.
	// Valid values are "Retain", "Delete", or "Recycle". Defaults to "Retain".
	// Ignored by Docker Compose.
	reclaimPolicy?: #ReclaimPolicy
	// The binding mode for the PersistentVolume.
	// Valid values are "Immediate" or "WaitForFirstConsumer". Defaults to "Immediate".
	// Ignored by Docker Compose.
	bindingMode?: #BindingMode

	// Docker compose specific options. Commented out, because don't know if we need them.
	// // The driver to use for the volume.
	// driver?: string & strings.MaxRunes(256)
	// // The driver options to use for the volume.
	// driverOptions?: {
	// 	{[=~"^.+$"]: number | string}
	// 	...
	// }
	// external?: bool | string | close({
	// 	// Specifies the name of the external volume. Deprecated: use the
	// 	// 'name' property instead.
	// 	name?: string @deprecated()

	// 	{[=~"^x-" & !~"^(name)$"]: _}
	// })
	// labels?: matchN(1, [close({
	// 	{[=~".+"]: null | bool | number | string}
	// }), list.UniqueItems() & [...string]])
}

#VolumeMount: {
	// This must match the Name of a Volume.
	name: string & strings.MaxRunes(256)
	// Mounted read-only if true, read-write otherwise (false or unspecified).
	readOnly?: bool | *false
	// RecursiveReadOnly specifies whether read-only mounts should be handled
	// recursively.
	//
	// If ReadOnly is false, this field has no meaning and must be unspecified.
	//
	// If ReadOnly is true, and this field is set to Disabled, the mount is not made
	// recursively read-only.  If this field is set to IfPossible, the mount is made
	// recursively read-only, if it is supported by the container runtime.  If this
	// field is set to Enabled, the mount is made recursively read-only if it is
	// supported by the container runtime, otherwise the pod will not be started and
	// an error will be generated to indicate the reason.
	//
	// If this field is set to IfPossible or Enabled, MountPropagation must be set to
	// None (or be unspecified, which defaults to None).
	//
	// If this field is not specified, it is treated as an equivalent of Disabled.
	recursiveReadOnly?: *"Disabled" | "IfPossible" | "Enabled"
	// The actual mount path in the filesystem.
	// Sets the target directory in the container where the volume will be mounted.
	mountPath: string & strings.MaxRunes(1024)
	// Path within the volume from which the container's volume should be mounted.
	// Defaults to "" (volume's root).
	// Specifies which subdirectory or file within the volume should be mounted at the mountPath.
	subPath?: string & strings.MaxRunes(1024)
	// mountPropagation determines how mounts are propagated from the host
	// to container and the other way around.
	// When not set, MountPropagationNone is used.
	// This field is beta in 1.10.
	// When RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified
	// (which defaults to None).
	mountPropagation?: *"None" | "HostToContainer" | "Bidirectional"
	// Expanded path within the volume from which the container's volume should be mounted.
	// Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.
	// Defaults to "" (volume's root).
	// SubPathExpr and SubPath are mutually exclusive.
	subPathExpr?: string & strings.MaxRunes(1024)
}

#HostPathType: string | *"" | "Directory" | "File" | "Socket" | "CharDevice" | "BlockDevice" | "DirectoryOrCreate" | "FileOrCreate"

// PersistenceTypes defines the types of volumes that can be used in a workload.
// Borrows from Kubernetes but tries to keep it simple to be compatible with Docker Compose.
#PersistenceTypes: string & "emptyDir" | "configMap" | "secret" | "volume" | "hostPath"

// This is a list of access modes that can be used in a PersistentVolumeClaim.
#AccessModes: [string] | *["ReadWriteOnce"] | ["ReadOnlyMany"] | ["ReadWriteMany"] | ["ReadWriteOncePod"]

// VolumeMode defines the mode of the volume, either "Filesystem" or "Block".
// Filesystem volumes are mounted as directories, while Block volumes are mounted as block devices.
// Defaults to "Filesystem" if not specified.
#VolumeMode: string | *"Filesystem" | "Block"

// Reclaim policies for persistent volumes.
// "Retain" means the volume is not deleted when the PersistentVolumeClaim is deleted.
// "Delete" means the volume is deleted when the PersistentVolumeClaim is deleted.
// "Recycle" means the volume is deleted and recreated when the PersistentVolumeClaim is deleted.
#ReclaimPolicy: *"Retain" | "Delete" | "Recycle"

// Binding modes for persistent volumes.
// "Immediate" means the volume is bound immediately when created.
// "WaitForFirstConsumer" means the volume is bound when a pod that uses it is scheduled.
// This is useful for volumes that depend on the node where the pod is scheduled.
// It allows the volume to be created on the same node as the pod, which can be important for performance or availability.
#BindingMode: *"Immediate" | "WaitForFirstConsumer"

// KeyToPath defines the schema for mapping a key in a ConfigMap or Secret to a file path in a volume.
#KeyToPath: {
	// The key to the file in the ConfigMap or Secret.
	key: string & strings.MaxRunes(256)
	// The relative path to map the key to.
	path: string & strings.MaxRunes(1024)
	// The mode bits to use on this file, must be a value between 0000 and 0777.
	mode?: int & >=0o000 & <=0o777
}

// Placeholder for node affinity rules (topology constraints).
#NodeAffinity: {
	[string]: _
}
