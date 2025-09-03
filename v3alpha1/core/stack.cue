package core

import (
	"strings"
)

#DefaultAPIVersion: string | *"core.oam.dev/v3alpha1"
#Object: {
	#apiVersion:      #DefaultAPIVersion
	#kind:            string & strings.MinRunes(1) & strings.MaxRunes(253)
	#combinedVersion: string | "\(#apiVersion).\(#kind)"
	#metadata:        #ObjectMeta
	...
}

#ObjectMeta: {
	#id:        string & strings.MinRunes(1) & strings.MaxRunes(253)
	name:       string & strings.MinRunes(1) & strings.MaxRunes(253)
	namespace?: string & strings.MinRunes(1) & strings.MaxRunes(253)
	labels?: [string]:      string | int | bool
	annotations?: [string]: string | int | bool
	...
}

#Trait: {
	// Each trait can define its Kubernetes resources
	#kubernetesOutput?: [...]
	...
}

#Component: #Object & {
	#Trait

	// Component-level Kubernetes output that aggregates trait outputs
	#kubernetesOutput?: [...]
	#output: [...]
}

#Module: #Object & {
	components!: [Id=string]: #Component & {
		#metadata: #id: Id
	}
	// Module-level Kubernetes output that aggregates component outputs
	#kubernetesOutput?: [...]
	#output: [...]
}

#Vol: {
	type!: string | "emptyDir" | "volume"
	size?: string
}

/////////////////////////////////////////////////////////////
#Workload: #Trait & {
	// Define Kubernetes output for workload trait
    #output: kubernetes: [...{
		apiVersion: "apps/v1"
		kind:       "Deployment"
		spec: {
			replicas: 1
			selector: matchLabels: app: "web"
			template: {
				metadata: labels: app: "web"
				spec: containers: [for container in containers & {
					name:  container.name
					image: container.image
					env: [
						{name: "PORT", value: "8080"},
					]
					resources: {
						requests: {
							cpu:    "100m"
							memory: "128Mi"
						}
						limits: {
							cpu:    "500m"
							memory: "512Mi"
						}
					}
				}]
			}
		}
	}]

	containers: [string]: {
		image: string
		command: [...string]
		args: [...string]
		env: [string]: string
		mounts?: [...{
			volume:    #Vol
			mountPath: string
			readOnly:  bool
		}]
		resources: {
			requests?: {
				cpu?:    string
				memory?: string
			}
			limits?: {
				cpu?:    string
				memory?: string
			}
		}
	}
	containers: main: _
	restart: "onfail" | "never" | *"always"
	rollout?: {
		maxSurgePercentage?:     uint & <=100 & >=0
		minAvailablePercentage?: uint & <=100 & >=0
	}
}

#Volume: #Trait & {
	// Define Kubernetes output for volume trait
	#kubernetesOutput?: [...{
		apiVersion: string
		kind:       string
		...
	}]

	volumes: [string]: #Vol
	volumes: main:     _
}

/////////////////////////////////////////////////////////////
module: #Module & {
	#metadata: {
		name: "example-webservice"
	}
	components: {
		web: {
			#Volume
			volumes: main: {
				type: "emptyDir"
			}

			#Workload
			containers: main: {
				image: "nginx:latest"
				command: ["cowsay"]
				args: ["Hello DevX!"]
				mounts: [
					{
						volume:    volumes.main
						mountPath: "/data/dir"
						readOnly:  false
					},
				]
			}
		}
		database: {
			#Volume
			volumes: main: {
				type: "volume"
			}

			#Workload
			containers: main: {
				image: "postgresql:latest"
				command: ["cowsay"]
				args: ["Hello again!"]
				mounts: [
					{
						volume:    volumes.main
						mountPath: "/data/dir"
						readOnly:  true
					},
				]
			}
		}
	}
}
