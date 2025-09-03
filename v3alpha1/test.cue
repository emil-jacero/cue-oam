package v3alpha1

import (
	"strings"
)

//////////////////////////////////////////////
//// Core
//////////////////////////////////////////////
#Trait: {
	#metadata: {
		#id:  string & strings.MinRunes(1) & strings.MaxRunes(253)
		name: string & strings.MinRunes(1) & strings.MaxRunes(253) | *#id
	}
	...
}

#Scope: {
	#metadata: {
		#id:  string & strings.MinRunes(1) & strings.MaxRunes(253)
		name: string & strings.MinRunes(1) & strings.MaxRunes(253) | *#id
	}
	childs: [...#Trait]
	...
}

#Component: {
	#metadata: {
		#id:  string & strings.MinRunes(1) & strings.MaxRunes(253)
		name: string & strings.MinRunes(1) & strings.MaxRunes(253) | *#id
		labels?: [string]:      string
		annotations?: [string]: string
	}
	traits!: [string]: #Trait & {
		#metadata: #id: string
	}
}

#Application: {
	#metadata: {
		name:       string
		namespace?: string
		labels?: [string]:      string
		annotations?: [string]: string
	}
	components!: [Id=string]: #Component & {
		#metadata: #id: Id
	}
	scopes?: [Id=string]: #Scope & {
		#metadata: #id: Id
	}
}

//////////////////////////////////////////////
//// Scopes
//////////////////////////////////////////////
#SharedNetwork: #Scope & {
	...
}

//////////////////////////////////////////////
//// Traits
//////////////////////////////////////////////
// Defines a volume
#Vol: {
	name: string
	size: string
	...
}
#VolMount: #Vol & {
	mountPath!: string
	readOnly?:  bool | *false
}

// Defines one or more containers
// Can be reference by name in a component
#Workload: #Trait & {
	containers: [string]: {
		name:     string
		image:    string
		replicas: uint
		volumes: [...#VolMount]
	}
}

// A database trait that extends the workload trait
// Can be reference by name in a component
#Database: #Workload & {
	D=database: {
		databaseType: "mysql" | "postgres" | "mongodb" | "redis"
		version?:     string | *"latest"
		storage:      #VolMount
	}
	containers: main: {
		if D.databaseType == "postgres" {
			name:     "postgres"
			image:    "postgres:\(D.version)"
			replicas: 1
			volumes: [D.storage]
		}
	}
}

// Defines one or more volumes
// Can be reference by name in a component
#Volume: #Trait & {
	volumes: [string]: #Vol
}

// Defines one or more secrets
// Can be reference by name in a component
#Secret: #Trait & {
	secrets: [string]: {
		data: [string]: string
	}
}

// Defines one or more configurations
// Can be reference by name in a component
#Config: #Trait & {
	config: [string]: {
		data: [string]: string
	}
}

//////////////////////////////////////////////
//// Applications
//////////////////////////////////////////////
myApp: {
	scopes: {
		frontendAndBackend: #SharedNetwork & {
			childs: [components.web, components.database]
		}
	}
	components: {
		web: {
			#Workload
			containers: main: {
				name:     "nginx"
				image:    "nginx:latest"
				replicas: 3
				volumes: [web.volumes.frontendStorage & {mountPath: "/usr/share/nginx/html"}]
			}
			#Volume
			volumes: frontendStorage: {
				name: "frontend-storage"
				size: "1Gi"
			}
		}
		database: {
			#Database
			main: {
				databaseType: "postgres"
				version:      "15"
				storage:      database.volumes.database
			}
			#Volume
			volumes: database: {
				name: "database-storage"
				size: "5Gi"
			}

		}
	}
}
