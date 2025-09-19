package schema

import (
	"strings"
)

//////////////////////////////////////////////
//// Trait schemas
//////////////////////////////////////////////

#VolumeMount: #VolumeSpec & {
	// The actual mount path in the filesystem.
	// Sets the target directory in the container where the volume will be mounted.
	mountPath!: string

	// Path within the volume from which the container's volume should be mounted. Defaults to "" (volume's root).
	// Specifies which subdirectory or file within the volume should be mounted at the mountPath.
	subPath?: string & strings.MaxRunes(1024)

	// If specified, the volume mount will only mount a sub-path of the volume.
	readOnly?: bool | *false

	volumeMountOptions?: #VolumeMountOptions
}

// Volume is a generalized definition of a storage volume.
// It is inspired by Kubernetes volumes but tries to be compatible with Docker Compose as well.
#VolumeSpec: {
	// The name of the volume.
	name!: string & strings.MaxRunes(254)

	// The type of the storage volume.
	type!: #PersistenceTypes

	#emptyDir | #configMap | #secret | #hostPath | #volume

	// The actual mount path in the filesystem.
	// Sets the target directory in the container where the volume will be mounted.
	mountPath?: string
}

#emptyDir: {
	type: "emptyDir"
	// medium specifies the medium type of the emptyDir volume.
	// If not specified, defaults to "" (disk).
	// Valid values are "Memory" for memory-backed volumes.
	medium?: string & "Memory"
	// sizeLimit specifies the maximum size of the emptyDir volume.
	// If not specified, defaults to "" (no limit).
	sizeLimit?: string & #StorageQuantity
}

#configMap: {
	type: "configMap"
	// config is the config to treat as a volume.
	config!: #ConfigSpec
}

#secret: {
	type: "secret"
	// secret is the secret to treat as a volume.
	secret!: #SecretSpec
}

#hostPath: {
	type: "hostPath"
	// Path of the directory on the host.
	hostPath!: string & strings.MaxRunes(1024)
	// Type of the hostPath volume.
	// Valid values are "Directory", "File", "Socket", "CharDevice", "BlockDevice", "DirectoryOrCreate", "FileOrCreate".
	// If not specified, defaults to "".
	hostPathType: #HostPathType
}

#volume: #PersistentVolumeSpec

#PersistentVolumeSpec: {
	type: "volume"
	// The size of the volume, e.g. "1Gi".
	// Converted for docker compose to "1G" or "1GiB".
	size!: string & #StorageQuantity
	// The access modes for the PersistentVolume.
	// Valid values are "ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany", "ReadWriteOncePod".
	// If not specified, defaults to ["ReadWriteOnce"].
	// Ignored by Docker Compose.
	accessModes: #AccessModes
	// The storage class to use for the PersistentVolume.
	// If not specified, defaults to "standard" for Kubernetes.
	// Ignored by Docker Compose.
	storageClassName: string & strings.MaxRunes(256) | *"standard"
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

#VolumeMountOptions: {
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
	// RecursiveReadOnly specifies whether read-only mounts should be handled recursively.
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
	RecursiveReadOnly: string | *"Disabled" | "IfPossible" | "Enabled"
	// mountOptions is the list of mount options, e.g. ["ro", "soft"]. Not validated - mount will
	// simply fail if one is invalid.
	extraMountOptions: [...string]
}

#HostPathType: string | *"" | "Directory" | "File" | "Socket" | "CharDevice" | "BlockDevice" | "DirectoryOrCreate" | "FileOrCreate"

// PersistenceTypes defines the types of volumes that can be used in a workload.
// Borrows from Kubernetes but tries to keep it simple to be compatible with Docker Compose.
#PersistenceTypes: string & "emptyDir" | "configMap" | "secret" | "volume" | "hostPath"

// This is a list of access modes that can be used in a PersistentVolumeClaim.
#AccessModes: [string] | *["ReadWriteOnce"] | ["ReadOnlyMany"] | ["ReadWriteMany"] | ["ReadWriteOncePod"]

// AccessMode defines the access mode for a volume.
// Must be one of "ReadWrite" or "ReadOnly".
#AccessMode: string | "ReadWrite" | "ReadOnly"

// VolumeMode defines the mode of the volume, either "Filesystem" or "Block".
// Filesystem volumes are mounted as directories, while Block volumes are mounted as block devices.
// Defaults to "Filesystem" if not specified.
#VolumeMode: string | *"Filesystem" | "Block"

// Reclaim policies for persistent volumes.
// "Retain" means the volume is not deleted when the PersistentVolumeClaim is deleted.
// "Delete" means the volume is deleted when the PersistentVolumeClaim is deleted.
// "Recycle" means the volume is deleted and recreated when the PersistentVolumeClaim is deleted.
#ReclaimPolicy: string | *"Retain" | "Delete" | "Recycle"

// Binding modes for persistent volumes.
// "Immediate" means the volume is bound immediately when created.
// "WaitForFirstConsumer" means the volume is bound when a pod that uses it is scheduled.
// This is useful for volumes that depend on the node where the pod is scheduled.
// It allows the volume to be created on the same node as the pod, which can be important for performance or availability.
#BindingMode: string | *"Immediate" | "WaitForFirstConsumer"
