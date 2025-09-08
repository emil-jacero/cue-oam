package storage

import (
	core "jacero.io/oam/core/v2alpha2"
)

#StorageClass: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "StorageClass"
	
	description: "Kubernetes StorageClass for defining classes of storage"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/storage/v1.StorageClass",
	]
	
	provides: {
		storageclass: {
			// StorageClass metadata
			metadata: {
				name: string
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// Provisioner indicates the type of the provisioner
			provisioner: string
			
			// Parameters holds the parameters for the provisioner that should create volumes
			parameters?: [string]: string
			
			// Reclaim policy for PersistentVolumes dynamically created by this class
			reclaimPolicy?: "Retain" | "Delete" | *"Delete"
			
			// AllowVolumeExpansion shows whether the storage class allow volume expand
			allowVolumeExpansion?: bool
			
			// MountOptions controls the mountOptions for dynamically provisioned PersistentVolumes
			mountOptions?: [...string]
			
			// VolumeBindingMode indicates how PersistentVolumeClaims should be provisioned and bound
			volumeBindingMode?: "Immediate" | "WaitForFirstConsumer" | *"Immediate"
			
			// AllowedTopologies restrict the node topologies where volumes can be dynamically provisioned
			allowedTopologies?: [...{
				matchLabelExpressions?: [...{
					key:    string
					values: [...string]
				}]
			}]
		}
	}
}