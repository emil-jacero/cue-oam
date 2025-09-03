package transformer

import (
	"jacero.io/oam/v3alpha1/core"
)

// Transform a module into a list of Kubernetes resources
#KubernetesTransformer: {
	// Input module
	#module: core.#Module
	
	// Output as a list of Kubernetes resources
	resources: [...#KubernetesResource]
	
	// Generate resources from components
	resources: [
		for name, component in #module.components {
			if component.containers != _|_ {
				// Generate Deployment for workload components
				{
					apiVersion: "apps/v1"
					kind:       "Deployment"
					metadata: {
						name:      name
						namespace: *#module.#metadata.namespace | "default"
						labels: {
							"app":                     name
							"oam.dev/component":       name
							"oam.dev/application":     #module.#metadata.name
						}
					}
					spec: {
						replicas: *1 | int
						selector: matchLabels: {
							"app": name
						}
						template: {
							metadata: labels: {
								"app":                     name
								"oam.dev/component":       name
								"oam.dev/application":     #module.#metadata.name
							}
							spec: containers: [
								for cname, container in component.containers {
									{
										name:    cname
										image:   container.image
										if container.command != _|_ {
											command: container.command
										}
										if container.args != _|_ {
											args: container.args
										}
										if container.env != _|_ && len(container.env) > 0 {
											env: [
												for k, v in container.env {
													{
														name:  k
														value: v
													}
												}
											]
										}
										if container.mounts != _|_ && len(container.mounts) > 0 {
											volumeMounts: [
												for mount in container.mounts {
													{
														name:      "volume-\(mount.mountPath)"
														mountPath: mount.mountPath
														readOnly:  mount.readOnly
													}
												}
											]
										}
										if container.resources != _|_ {
											resources: container.resources
										}
									}
								}
							]
							if component.containers != _|_ {
								let mounts = [
									for cname, container in component.containers if container.mounts != _|_ 
									for mount in container.mounts {mount}
								]
								if len(mounts) > 0 {
									spec: volumes: [
										for mount in mounts {
											{
												name: "volume-\(mount.mountPath)"
												if mount.volume.type == "emptyDir" {
													emptyDir: {}
												}
												if mount.volume.type == "volume" && mount.volume.size != _|_ {
													persistentVolumeClaim: claimName: "pvc-\(mount.mountPath)"
												}
											}
										}
									]
								}
							}
						}
					}
				}
			}
			if component.volumes != _|_ && component.containers == _|_ {
				// Generate PersistentVolume for volume-only components
				for vname, volume in component.volumes {
					{
						apiVersion: "v1"
						kind:       "PersistentVolume"
						metadata: {
							name: "\(name)-\(vname)"
							labels: {
								"oam.dev/component":   name
								"oam.dev/application": #module.#metadata.name
							}
						}
						spec: {
							if volume.size != _|_ {
								capacity: storage: volume.size
							}
							if volume.size == _|_ {
								capacity: storage: "1Gi"
							}
							accessModes: ["ReadWriteMany"]
							if volume.type == "emptyDir" {
								emptyDir: {}
							}
							if volume.type == "volume" {
								hostPath: path: "/data/\(name)-\(vname)"
							}
						}
					}
				}
			}
		}
	]
}

// Base Kubernetes resource structure
#KubernetesResource: {
	apiVersion: string
	kind:       string
	metadata:   #KubernetesMetadata
	spec:       {...}
	...
}

#KubernetesMetadata: {
	name:      string
	namespace?: string
	labels?: [string]:      string
	annotations?: [string]: string
	...
}