package v3alpha1

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
	#output?: [...]
	...
}

#Scope: {
	// Each scope can define its Kubernetes resources
	#output?: [...]
	...
}

#Component: #Object & {
	#Trait
	#Scope

	#output: [...]
}

#Module: #Object & {
	components!: [Id=string]: #Component & {
		#metadata: #id: Id
	}
	#output: [...]
}

#Vol: {
	type!: string | "emptyDir" | "volume"
	size?: string
}

/////////////////////////////////////////////////////////////
#Workload: #Trait & {
	// Define Kubernetes output for workload trait
    #output: [...{
		apiVersion: "apps/v1"
		kind:       "Deployment"
		spec: {
			replicas: 1
			selector: matchLabels: app: #metadata.#id
			template: {
				metadata: labels: app: #metadata.#id
				spec: containers: [for container in C & {
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

	C=containers: [string]: {
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
	#output?: [...{
		apiVersion: string
		kind:       string
		...
	}]

	volumes: [string]: #Vol
	volumes: main:     _
}

#Network: #Scope & {
	#output?: [...{
		apiVersion: "networking.k8s.io/v1"
		kind:       "NetworkPolicy"
		spec: {
			podSelector: matchLabels: app: "web"
			ingress: [
				{
					from: [
						{podSelector: matchLabels: app: "frontend"}
					]
				}
			]
		}
	}]
	networkSpec: {
		name: string | "example-network"
	}
}

/////////////////////////////////////////////////////////////
module: #Module & {
	#metadata: {
		name: "example-webservice"
	}
	#components: {
		net: {
			#Network
			networkSpec: {
				name: "my-network"
			}
		}
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