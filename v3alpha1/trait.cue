package v3alpha1

import (
)

// General rules:
// 1. Name should always default to the #id of the parent definition. For example the name of the database should by default become the ID passed in from the component.
// 2. Traits can be referenced by name in the same component or other components.
// 3. Traits can extend other traits.

//////////////////////////////////////////////
//// Trait schemas
//////////////////////////////////////////////

// Defines a volume
#Vol: {
	type!: "volume" | *"emptyDir"
	name:  string
	if type == "volume" {
		size!: string
	}
	...
}

// Extends volume and defines a volume mount
#VolMount: #Vol & {
	mountPath!: string
	readOnly?:  bool | *false
}

// Defines an environment variable
#EnvVar: {
	name:       string
	value:      string
	valueFrom?: #EnvFromSource
}

// EnvVarSource represents a source for environment variables.
// For example, a secret or config map key.
// TODO: Add support for targeting specific fields in a resource or remapping keys.
#EnvFromSource: {
	// Selects a key of a ConfigMap.
	config?: #ConfigSpec
	// Selects a key of a secret in the pod's namespace
	secret?: #SecretSpec
	// An optional identifier to prepend to each key in the ConfigMap.
	prefix?: string
}

// Defines a secret specification
#SecretSpec: {
	data: [string]: string
}

// Defines a configuration specification
#ConfigSpec: {
	data: [string]: string
}

//////////////////////////////////////////////
//// Traits
//////////////////////////////////////////////

// Defines one or more volumes
#Volume: #Trait & {
	#metadata: #traits: Volume: {
		provides: ["volumes"]
		description: "Describes a named set of volumes"
	}
	volumes: [string]: #Vol
}

// Defines one or more containers
#Workload: #Trait & {
	#metadata: {
		#traits: Workload: {
			provides: ["containers", "replicas"]
			description: "Describes a workload with one or multiple containers. The main container is treated as the primary container."
		}
	}
	containers: main: {
		name:  string
		image: string
		command?: [...string]
		args?: [...string]
		env?: [...#EnvVar]
		replicas?: uint32 | *1
		volumes: [...#VolMount]
	}
}

// A database trait that extends the workload trait
#Database: #Workload & {
	#metadata: {
		#traits: Database: {
			extends: "Workload"
			provides: ["containers", "replicas", "database"]
			description: "Describes a database workload"
		}
	}
	D=database: {
		databaseType: string | *"postgres" | "mysql"
		version:      string | *"16"
		volume:       #VolMount
		if D.databaseType == "postgres" {
			postgres: {
				configFrom: #ConfigSpec
			}
		}
	}
	// containers: #Workload.containers // Inherited from Workload
	containers: main: {
		if D.databaseType == "postgres" {
			name:     "postgres"
			image:    "postgres:\(D.version)"
			replicas: 1
			volumes: [D.volume]
			env: [for key, value in D.postgres.configFrom.data {
				name:  key
				value: value
			}]
		}
	}
}

// Defines one or more secrets
#Secret: #Trait & {
	#metadata: #traits: Secret: {
		provides: ["secrets"]
		description: "Describes a set of secrets"
	}
	secret: [string]: #SecretSpec
}

// Defines one or more configurations
#Config: #Trait & {
	#metadata: #traits: Config: {
		provides: ["configurations"]
		description: "Describes a set of configurations"
	}
	config: [string]: #ConfigSpec
}
