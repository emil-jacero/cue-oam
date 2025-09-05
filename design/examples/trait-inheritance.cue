package examples

// Base trait
#Workload: #ComponentTrait & {
	#metadata: #traits: Workload: {
		category: "component"
		provides: workload: #Workload.workload
		requires: [
			"core.oam.dev/v2alpha1.Workload",
		]
	}

	workload: {
		containers: [string]: {...}
		containers: main: {name: string | *#metadata.name}
	}
}

// Extended trait
#Database: #ComponentTrait & {
	#metadata: #traits: Database: {
		category: "component"
		provides: database: #Database.database
		requires: [
			"core.oam.dev/v2alpha1.Workload",
			"core.oam.dev/v2alpha1.Volume",
			"core.oam.dev/v2alpha1.Config",
		]
		extends: [#Workload.#metadata.#traits.Workload]
	}

	database: {
		type:      "postgres" | "mysql" | "mongodb"
		replicas?: uint | *1
		version:   string
		persistence: {
			enabled: bool | *true
			size:    string | *"10Gi"
		}
	}

	// Inherited fields
	for t in #metadata.#traits.Database.extends {
		t.provides
	}
}
