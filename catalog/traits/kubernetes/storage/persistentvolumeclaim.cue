package storage

import (
	core "jacero.io/oam/core/v2alpha2"
)

#PersistentVolumeClaim: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "PersistentVolumeClaim"
	
	description: "Kubernetes PersistentVolumeClaim for requesting persistent storage"
	
	type:     "atomic"
	category: "resource"
	scope: ["component"]
	
	requiredCapabilities: [
		"k8s.io/api/core/v1.PersistentVolumeClaim",
	]
	
	provides: {
		persistentvolumeclaim: {
			// PersistentVolumeClaim metadata
			metadata: {
				name:      string
				namespace: string | *"default"
				labels: [string]:      string
				annotations: [string]: string
			}
			
			// PersistentVolumeClaim specification
			spec: {
				// AccessModes contains the desired access modes the volume should have
				accessModes?: [...("ReadWriteOnce" | "ReadOnlyMany" | "ReadWriteMany" | "ReadWriteOncePod")]
				
				// Selector is a label query over volumes to consider for binding
				selector?: {
					matchLabels?: [string]: string
					matchExpressions?: [...{
						key:      string
						operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
						values?: [...string]
					}]
				}
				
				// Resources represents the minimum resources the volume should have
				resources?: {
					limits?: {
						storage?: string
						[string]: string
					}
					requests?: {
						storage?: string
						[string]: string
					}
				}
				
				// VolumeName is the binding reference to the PersistentVolume backing this claim
				volumeName?: string
				
				// StorageClassName is the name of the StorageClass required by the claim
				storageClassName?: string | null
				
				// VolumeMode defines what type of volume is required by the claim
				volumeMode?: "Filesystem" | "Block" | *"Filesystem"
				
				// DataSource field can be used to specify either an existing VolumeSnapshot object
				dataSource?: {
					name:      string
					kind:      string
					apiGroup?: string
				}
				
				// DataSourceRef specifies the object from which to populate the volume with data
				dataSourceRef?: {
					name:       string
					kind:       string
					apiGroup?:  string
					namespace?: string
				}
			}
			
			// PersistentVolumeClaim status
			status?: {
				// Phase represents the current phase of PersistentVolumeClaim
				phase?: "Pending" | "Bound" | "Lost"
				
				// AccessModes contains the actual access modes the volume backing the PVC has
				accessModes?: [...("ReadWriteOnce" | "ReadOnlyMany" | "ReadWriteMany" | "ReadWriteOncePod")]
				
				// Capacity represents the actual resources of the underlying volume
				capacity?: [string]: string
				
				// Conditions is an array of current conditions
				conditions?: [...{
					type:               "Resizing" | "FileSystemResizePending"
					status:             "True" | "False" | "Unknown"
					lastProbeTime?:     string
					lastTransitionTime: string
					reason?:            string
					message?:           string
				}]
				
				// AllocatedResources tracks the resources allocated to a PVC including its capacity
				allocatedResources?: [string]: string
				
				// ResizeStatus stores the status of the capacity resizing operation
				resizeStatus?: "ControllerResizeInProgress" | "NodeResizeInProgress" | "ControllerResizeFailed" | "NodeResizeFailed"
			}
		}
	}
}