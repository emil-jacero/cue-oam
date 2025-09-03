package v3alpha1

import (
	"list"
)

//////////////////////////////////////////////
// Kubernetes Resource Definitions
//////////////////////////////////////////////

#K8sResource: {
	apiVersion: string
	kind:       string
	metadata: {
		name:      string
		namespace: string | *"default"
		labels?: [string]:      string
		annotations?: [string]: string
	}
	...
}

#K8sDeployment: #K8sResource & {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	spec: {
		replicas: int | *1
		selector: matchLabels: [string]: string
		template: {
			metadata: labels: [string]: string
			spec: containers: [...{
				name:  string
				image: string
				env?: [...{
					name:  string
					value: string
				}]
				volumeMounts?: [...{
					name:      string
					mountPath: string
					readOnly:  bool | *false
				}]
				command?: [...string]
				args?: [...string]
			}]
			spec: volumes?: [...{
				name: string
				persistentVolumeClaim?: claimName: string
				configMap?: name:                  string
				secret?: secretName:               string
				emptyDir?: {}
			}]
		}
	}
}

#K8sPVC: #K8sResource & {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	spec: {
		accessModes: [...string]
		resources: requests: storage: string
	}
}

#K8sConfigMap: #K8sResource & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	data: [string]: string
}

#K8sSecret: #K8sResource & {
	apiVersion: "v1"
	kind:       "Secret"
	type:       string | *"Opaque"
	stringData: [string]: string
}

#K8sService: #K8sResource & {
	apiVersion: "v1"
	kind:       "Service"
	spec: {
		selector: [string]: string
		ports: [...{
			port:       int
			targetPort: int | string
			protocol:   string | *"TCP"
		}]
		type: string | *"ClusterIP"
	}
}

#K8sNetworkPolicy: #K8sResource & {
	apiVersion: "networking.k8s.io/v1"
	kind:       "NetworkPolicy"
	spec: {
		podSelector: matchLabels: [string]: string
		policyTypes: [...string]
		ingress?: [...{
			from?: [...{
				podSelector?: matchLabels: [string]: string
			}]
		}]
		egress?: [...{
			to?: [...{
				podSelector?: matchLabels: [string]: string
			}]
		}]
	}
}

//////////////////////////////////////////////
// Kubernetes Trait Transformers
//////////////////////////////////////////////

// Transform #Workload trait to Kubernetes Deployment
#WorkloadTransformer: {
	input:   #Workload
	context: #ProviderContext
	output: {
		deployment: #K8sDeployment & {
			metadata: {
				name:      context.componentName
				namespace: context.namespace
				labels: context.appLabels & {
					"app.oam.dev/component": context.componentId
					"app.oam.dev/name":      context.appName
				}
			}
			spec: {
				replicas: input.replicas | *1
				selector: matchLabels: {
					"app.oam.dev/component": context.componentId
				}
				template: {
					metadata: labels: {
						"app.oam.dev/component": context.componentId
						"app.oam.dev/name":      context.appName
					}
					spec: containers: [
						for cname, container in input.containers {
							name:  container.name
							image: container.image
							if container.command != _|_ {
								command: container.command
							}
							if container.args != _|_ {
								args: container.args
							}

							// if container.env != _|_ {
							// 	env: container.env
							// }
							if container.volumeMounts != _|_ {
								volumeMounts: [
									for vm in container.volumeMounts {
										name:      vm.name
										mountPath: vm.mountPath
										if vm.readOnly != _|_ {
											readOnly: vm.readOnly
										}
									},
								]
							}
						},
					]
				}
			}
		}
	}
}

// Transform #Volume trait to Kubernetes PVC
#VolumeTransformer: {
	input:   #Volume
	context: #ProviderContext
	output: {
		pvcs: [
			for vname, vol in input.volumes if vol.type == "volume" {
				#K8sPVC & {
					metadata: {
						name:      "\(context.componentName)-\(vol.name)"
						namespace: context.namespace
						labels: context.appLabels & {
							"app.oam.dev/component": context.componentId
							"app.oam.dev/volume":    vname
						}
					}
					spec: {
						accessModes: ["ReadWriteOnce"]
						resources: requests: storage: vol.size
					}
				}
			},
		]
		// Add volume definitions to be merged into deployment
		volumes: [
			for vname, vol in input.volumes {
				name: vol.name
				if vol.type == "volume" {
					persistentVolumeClaim: claimName: "\(context.componentName)-\(vol.name)"
				}
				if vol.type == "emptyDir" {
					emptyDir: {}
				}
			},
		]
	}
}

// Transform #Config trait to Kubernetes ConfigMap
#ConfigTransformer: {
	input:   #Config
	context: #ProviderContext
	output: {
		configmaps: [
			for cname, cfg in input.config {
				#K8sConfigMap & {
					metadata: {
						name:      "\(context.componentName)-\(cname)"
						namespace: context.namespace
						labels: context.appLabels & {
							"app.oam.dev/component": context.componentId
							"app.oam.dev/config":    cname
						}
					}
					data: cfg.data
				}
			},
		]
	}
}

// Transform #Secret trait to Kubernetes Secret
#SecretTransformer: {
	input:   #Secret
	context: #ProviderContext
	output: {
		secrets: [
			for sname, secret in input.secret {
				#K8sSecret & {
					metadata: {
						name:      "\(context.componentName)-\(sname)"
						namespace: context.namespace
						labels: context.appLabels & {
							"app.oam.dev/component": context.componentId
							"app.oam.dev/secret":    sname
						}
					}
					stringData: secret.data
				}
			},
		]
	}
}

// Transform #Database trait (which extends Workload)
#DatabaseTransformer: {
	input:   #Database
	context: #ProviderContext

	// Database is a specialized Workload, so we reuse WorkloadTransformer
	_workloadTransform: #WorkloadTransformer & {
		"input":   input
		"context": context
	}

	output: {
		deployment: _workloadTransform.output.deployment
		// Database might need a service for stable DNS
		service: #K8sService & {
			metadata: {
				name:      context.componentName
				namespace: context.namespace
				labels: context.appLabels & {
					"app.oam.dev/component": context.componentId
					"app.oam.dev/type":      "database"
				}
			}
			spec: {
				selector: {
					"app.oam.dev/component": context.componentId
				}
				ports: [
					if input.database.databaseType == "postgres" {
						port:       5432
						targetPort: 5432
					},
					if input.database.databaseType == "mysql" {
						port:       3306
						targetPort: 3306
					},
				]
			}
		}
	}
}

//////////////////////////////////////////////
// Kubernetes Component Processor
//////////////////////////////////////////////

#ComponentProcessor: {
	component: #Component
	context:   #ProviderContext

	// Extract traits that the component has using metadata
	_traits: {
		// For each trait declared in #metadata.#traits, extract its fields from the component
		for traitName, traitMeta in component.#metadata.#traits {
			"\(traitName)": {
				// Extract all fields declared for this trait
				for fieldName in traitMeta.fields {
					if component[fieldName] != _|_ {
						"\(fieldName)": component[fieldName]
					}
				}

				// Add metadata for reference
				#metadata: component.#metadata
			}
		}
	}

	// Process each trait and collect resources
	_resources: {
		// Process Workload trait
		if _traits.Workload != _|_ {
			workload: #WorkloadTransformer & {
				input:     _traits.Workload
				"context": context
			}
		}

		// Process Database trait (overrides Workload if both exist)
		if _traits.Database != _|_ {
			database: #DatabaseTransformer & {
				input:     _traits.Database
				"context": context
			}
		}

		// Process Volume trait
		if _traits.Volume != _|_ {
			volume: #VolumeTransformer & {
				input:     _traits.Volume
				"context": context
			}
		}

		// Process Config trait
		if _traits.Config != _|_ {
			config: #ConfigTransformer & {
				input:     _traits.Config
				"context": context
			}
		}

		// Process Secret trait
		if _traits.Secret != _|_ {
			secret: #SecretTransformer & {
				input:     _traits.Secret
				"context": context
			}
		}
	}

	// Get base deployment
	_baseDeployment: {
		if _resources.database != _|_ {
			_resources.database.output.deployment
		}
		if _resources.database == _|_ && _resources.workload != _|_ {
			_resources.workload.output.deployment
		}
	}

	// Merge volumes into deployment if both exist
	_deployment: {
		if _baseDeployment != _|_ {
			_baseDeployment

			// Inject volumes if they exist
			if _resources.volume != _|_ {
				spec: template: spec: volumes: _resources.volume.output.volumes
			}
		}
	}

	// Collect all resources
	output: {
		resources: list.FlattenN([
			// Deployment (from Workload or Database)
			if _deployment != _|_ {[_deployment]},

			// Database service
			if _resources.database != _|_ {[_resources.database.output.service]},

			// PVCs from Volume trait
			if _resources.volume != _|_ {_resources.volume.output.pvcs},

			// ConfigMaps from Config trait
			if _resources.config != _|_ {_resources.config.output.configmaps},

			// Secrets from Secret trait
			if _resources.secret != _|_ {_resources.secret.output.secrets},
		], 1)
	}
}

//////////////////////////////////////////////
// Kubernetes Scope Handlers
//////////////////////////////////////////////

#ScopeProcessor: {
	scope: #Scope
	resources: [...#K8sResource]
	context: #ProviderContext

	// For SharedNetwork scope, create NetworkPolicy
	output: {
		if scope.#kind == "Scope" {
			networkPolicy: #K8sNetworkPolicy & {
				metadata: {
					name:      "\(context.appName)-\(scope.#metadata.#id)-network"
					namespace: context.namespace
					labels: context.appLabels & {
						"app.oam.dev/scope": scope.#metadata.#id
					}
				}
				spec: {
					// Apply to all components in the scope
					podSelector: matchLabels: {
						"app.oam.dev/name": context.appName
					}
					policyTypes: ["Ingress", "Egress"]
					// Allow traffic between components in the same scope
					ingress: [{
						from: [{
							podSelector: matchLabels: {
								"app.oam.dev/name": context.appName
							}
						}]
					}]
					egress: [{
						to: [{
							podSelector: matchLabels: {
								"app.oam.dev/name": context.appName
							}
						}]
					}]
				}
			}
		}
	}
}

//////////////////////////////////////////////
// Kubernetes Application Renderer
//////////////////////////////////////////////

#ApplicationRenderer: {
	app: #Application

	_context: #ProviderContext & {
		namespace:  app.#metadata.namespace | *"default"
		appName:    app.#metadata.name
		appVersion: app.#metadata.version
		appLabels: {
			"app.oam.dev/name":    app.#metadata.name
			"app.oam.dev/version": app.#metadata.version
		}
	}

	// Process all components
	_componentResources: {
		for cid, comp in app.components {
			"\(cid)": #ComponentProcessor & {
				component: comp
				context: _context & {
					componentName: comp.#metadata.name | *cid
					componentId:   cid
				}
			}
		}
	}

	// Process all scopes
	_scopeResources: {
		for sid, scope in app.scopes if app.scopes != _|_ {
			"\(sid)": #ScopeProcessor & {
				"scope": scope
				resources: [] // Would collect resources from components in scope
				context:      _context
			}
		}
	}

	// Collect all resources
	output: {
		apiVersion: "v1"
		kind:       "List"
		items: list.FlattenN([
			// All component resources
			for cid, proc in _componentResources {
				proc.output.resources
			},
			// All scope resources
			for sid, proc in _scopeResources if proc.output != _|_ {
				[proc.output.networkPolicy]
			},
		], 1)
	}
}