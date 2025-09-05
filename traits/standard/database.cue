// package standard

// import (
// 	corev2 "jacero.io/oam/core/v2alpha1"
// 	traitsschema "jacero.io/oam/traits/schema"
// )

// // A database trait that extends the workload trait
// #Database: #Workload & {
// 	#metadata: {
// 		#traits: Database: {
// 			extends: ["Workload"]
// 			provides: ["containers", "replicas", "database"]
// 			description: "Describes a database workload"
// 			fields: ["containers", "replicas", "database"]
// 		}
// 	}

// 	// Database specific fields
// 	D=database: {
// 		databaseType: string | *"postgres" | "mysql"
// 		version:      string | *"16"
// 		volumeMount:  schemav3.#VolMount
// 		if D.databaseType == "postgres" {
// 			postgres: {
// 				configFrom: schemav3.#ConfigSpec
// 			}
// 		}
// 	}

// 	// Workload fields
// 	replicas: uint32 | *1
// 	containers: [string]: schemav3.#ContainerSpec
// 	containers: main: {
// 		if D.databaseType == "postgres" {
// 			name: "postgres"
// 			image: {repository: "postgres", tag: D.version}
// 			volumeMounts: [D.volumeMount]
// 			env: [for key, value in D.postgres.configFrom.data {
// 				name:  key
// 				value: value
// 			}]
// 		}
// 	}
// }
