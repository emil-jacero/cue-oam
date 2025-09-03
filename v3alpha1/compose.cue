package v3alpha1

//////////////////////////////////////////////
// Docker Compose Resource Definitions
//////////////////////////////////////////////

#ComposeService: {
	image?: string
	build?: {
		context:    string
		dockerfile: string | *"Dockerfile"
		args?: [string]: string
	}
	command?: string | [...string]
	environment?: [string]: string | int | bool
	ports?: [...string]
	volumes?: [...string]
	depends_on?: [...string]
	networks?: [...string]
	restart?: string | *"unless-stopped"
	deploy?: {
		replicas?: int | *1
		resources?: {
			limits?: {
				cpus?:   string
				memory?: string
			}
			reservations?: {
				cpus?:   string
				memory?: string
			}
		}
	}
	labels?: [string]: string
	...
}

#ComposeVolume: {
	driver?: string | *"local"
	driver_opts?: [string]: string
	external?: bool | *false
	name?:     string
	labels?: [string]: string
	...
}

#ComposeNetwork: {
	driver?: string | *"bridge"
	driver_opts?: [string]: string
	external?: bool | *false
	name?:     string
	labels?: [string]: string
	attachable?: bool | *false
	...
}

#ComposeConfig: {
	file?:     string
	external?: bool | *false
	name?:     string
	labels?: [string]: string
	...
}

#ComposeSecret: {
	file?:     string
	external?: bool | *false
	name?:     string
	labels?: [string]: string
	...
}

#DockerCompose: {
	version?: string | *"3.8"
	services: [string]:  #ComposeService
	volumes?: [string]:  #ComposeVolume
	networks?: [string]: #ComposeNetwork
	configs?: [string]:  #ComposeConfig
	secrets?: [string]:  #ComposeSecret
}

//////////////////////////////////////////////
// Docker Compose Trait Transformers
//////////////////////////////////////////////

// Transform #Workload trait to Docker Compose service
#ComposeWorkloadTransformer: {
	input:   #Workload
	context: #ProviderContext
	output: {
		service: #ComposeService & {
			if input.containers.main.image != _|_ {
				image: input.containers.main.image
			}
			if input.containers.main.command != _|_ {
				command: input.containers.main.command
			}
			if input.containers.main.args != _|_ {
				// In compose, args are appended to command
				if input.containers.main.command != _|_ {
					command: input.containers.main.command + input.containers.main.args
				}
				if input.containers.main.command == _|_ {
					command: input.containers.main.args
				}
			}
			if input.replicas != _|_ && input.replicas > 1 {
				deploy: replicas: input.replicas
			}
			if input.containers.main.volumeMounts != _|_ {
				volumes: [
					for vm in input.containers.main.volumeMounts {
						if vm.readOnly != _|_ {
							if vm.readOnly {
								"\(vm.name):\(vm.mountPath):ro"
							}
							if !vm.readOnly {
								"\(vm.name):\(vm.mountPath)"
							}
						}
						if vm.readOnly == _|_ {
							"\(vm.name):\(vm.mountPath)"
						}
					},
				]
			}
			labels: {
				"oam.component": context.componentId
				"oam.app":       context.appName
			}
		}
	}
}

// Transform #Volume trait to Docker Compose volumes
#ComposeVolumeTransformer: {
	input:   #Volume
	context: #ProviderContext
	output: {
		volumes: {
			for vname, vol in input.volumes {
				(vol.name): #ComposeVolume & {
					labels: {
						"oam.component": context.componentId
						"oam.volume":    vname
					}
				}
			}
		}
	}
}

// Transform #Config trait to Docker Compose configs and environment
#ComposeConfigTransformer: {
	input:   #Config
	context: #ProviderContext
	output: {
		configs: {
			for cname, cfg in input.config {
				"\(context.componentName)-\(cname)": #ComposeConfig & {
					file: "./config/\(context.componentName)-\(cname).env"
					labels: {
						"oam.component": context.componentId
						"oam.config":    cname
					}
				}
			}
		}
		// Also provide as environment variables for easier integration
		environment: {
			// Flatten all config data into environment
			for cname, cfg in input.config
			for key, value in cfg.data {
				(key): "\(value)"
			}
		}
	}
}

// Transform #Secret trait to Docker Compose secrets
#ComposeSecretTransformer: {
	input:   #Secret
	context: #ProviderContext
	output: {
		secrets: {
			for sname, secret in input.secret {
				"\(context.componentName)-\(sname)": #ComposeSecret & {
					file: "./secrets/\(context.componentName)-\(sname).txt"
					labels: {
						"oam.component": context.componentId
						"oam.secret":    sname
					}
				}
			}
		}
	}
}

// Transform #Database trait to Docker Compose service
#ComposeDatabaseTransformer: {
	input:   #Database
	context: #ProviderContext

	// Database is a specialized Workload, so we reuse ComposeWorkloadTransformer
	_workloadTransform: #ComposeWorkloadTransformer & {
		"input":   input
		"context": context
	}

	output: {
		service: _workloadTransform.output.service & {
			// Add database-specific ports
			ports: [
				if input.database.databaseType == "postgres" {
					"5432:5432"
				},
				if input.database.databaseType == "mysql" {
					"3306:3306"
				},
			]
			// Add environment variables from postgres config if available
			if input.database.databaseType == "postgres" && input.database.postgres.configFrom.data != _|_ {
				environment: {
					for key, value in input.database.postgres.configFrom.data {
						(key): "\(value)"
					}
				}
			}
		}
	}
}

//////////////////////////////////////////////
// Docker Compose Component Processor
//////////////////////////////////////////////

#ComposeComponentProcessor: {
	component: #Component
	context:   #ProviderContext

	// Extract traits that the component has using metadata (same as K8s processor)
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

	// Process each trait and collect Compose resources
	_resources: {
		// Process Workload trait
		if _traits.Workload != _|_ {
			workload: #ComposeWorkloadTransformer & {
				input:     _traits.Workload
				"context": context
			}
		}

		// Process Database trait (overrides Workload if both exist)
		if _traits.Database != _|_ {
			database: #ComposeDatabaseTransformer & {
				input:     _traits.Database
				"context": context
			}
		}

		// Process Volume trait
		if _traits.Volume != _|_ {
			volume: #ComposeVolumeTransformer & {
				input:     _traits.Volume
				"context": context
			}
		}

		// Process Config trait
		if _traits.Config != _|_ {
			config: #ComposeConfigTransformer & {
				input:     _traits.Config
				"context": context
			}
		}

		// Process Secret trait
		if _traits.Secret != _|_ {
			secret: #ComposeSecretTransformer & {
				input:     _traits.Secret
				"context": context
			}
		}
	}

	// Get the base service definition
	_baseService: {
		if _resources.database != _|_ {
			_resources.database.output.service
		}
		if _resources.database == _|_ && _resources.workload != _|_ {
			_resources.workload.output.service
		}
	}

	// Get the final service definition with config environment merged
	_service: {
		if _baseService != _|_ {
			_baseService

			// Merge environment from configs
			if _resources.config != _|_ {
				environment: _resources.config.output.environment
			}
		}
	}

	// Collect all Compose resources for this component
	output: {
		// Service definition
		service: {
			if _service != _|_ {
				"\(context.componentName)": _service
			}
		}

		// Volume definitions
		volumes: {
			if _resources.volume != _|_ {
				_resources.volume.output.volumes
			}
		}

		// Config definitions  
		configs: {
			if _resources.config != _|_ {
				_resources.config.output.configs
			}
		}

		// Secret definitions
		secrets: {
			if _resources.secret != _|_ {
				_resources.secret.output.secrets
			}
		}
	}
}

//////////////////////////////////////////////
// Docker Compose Scope Handlers
//////////////////////////////////////////////

#ComposeScopeProcessor: {
	scope:   #Scope
	context: #ProviderContext

	output: {
		// For SharedNetwork scope, create a custom network
		if scope.#kind == "Scope" {
			network: {
				"\(context.appName)-\(scope.#metadata.#id)": #ComposeNetwork & {
					driver: "bridge"
					labels: {
						"oam.scope": scope.#metadata.#id
						"oam.app":   context.appName
					}
				}
			}
		}
	}
}

//////////////////////////////////////////////
// Docker Compose Application Renderer
//////////////////////////////////////////////

#ComposeApplicationRenderer: {
	app: #Application

	_context: #ProviderContext & {
		namespace:  app.#metadata.namespace | *"default"
		appName:    app.#metadata.name
		appVersion: app.#metadata.version
		appLabels: {
			"oam.name":    app.#metadata.name
			"oam.version": app.#metadata.version
		}
	}

	// Process all components
	_componentResources: {
		for cid, comp in app.components {
			"\(cid)": #ComposeComponentProcessor & {
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
			"\(sid)": #ComposeScopeProcessor & {
				"scope": scope
				context: _context
			}
		}
	}

	// Collect and merge all resources into a single Docker Compose structure
	output: #DockerCompose & {

		// Merge all services
		services: {
			for cid, proc in _componentResources {
				proc.output.service
			}
		}

		// Merge all volumes
		volumes: {
			for cid, proc in _componentResources if proc.output.volumes != _|_ {
				proc.output.volumes
			}
		}

		// Merge all configs
		configs: {
			for cid, proc in _componentResources if proc.output.configs != _|_ {
				proc.output.configs
			}
		}

		// Merge all secrets
		secrets: {
			for cid, proc in _componentResources if proc.output.secrets != _|_ {
				proc.output.secrets
			}
		}

		// Merge all networks (from scopes)
		networks: {
			for sid, proc in _scopeResources if proc.output.network != _|_ {
				proc.output.network
			}
		}
	}
}