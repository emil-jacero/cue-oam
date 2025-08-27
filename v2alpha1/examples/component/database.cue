package component

import (
	"strings"

	v2alpha1core "jacero.io/oam/v2alpha1/core"
	v2alpha1schema "jacero.io/oam/v2alpha1/schema"
	// v2alpha1compose "jacero.io/oam/v2alpha1/transformer/compose"
	v2alpha1workload "jacero.io/oam/v2alpha1/examples/workload"
)

#Database: v2alpha1core.#Component & {

	#metadata: {
		name:        "database.component.oam.dev"
		description: "A test component for the database workload."
		type:        "database"
	}

	workload: v2alpha1workload.#Server

	// Config are used to define the properties of the component,
	/// which can be used by the component owner to configure the outputs.
	config: workload.schema & {
		// The type of database. For example postgres.
		type: _ | *"mysql" | "postgres" | "mongodb"
		if type == "postgres" {
			version: string & strings.MaxRunes(64)
			postgresConfig: {
				// PostgreSQL role that owns the database. 
				owner: string | *"app"
				extensions: [...#PostgresExtension]
				backup: #PostgresBackup
			}
		}
		if type == "mysql" {
			version: string & strings.MaxRunes(64)
		}
		if type == "mongodb" {
			version: string & strings.MaxRunes(64)
		}

		// The persistent volume for the database.
		volume: v2alpha1schema.#Volume
	}

	template: {
		compose: {}
	}
}

#PostgresExtension: {
	name:   string & strings.MaxRunes(64)
	ensure: string | *"present"
}

#PostgresBackup: {
	schedule:  string | *"daily"
	retention: string | *"7d"
}
