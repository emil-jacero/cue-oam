package core

// import (
// 	v2alpha1compose "jacero.io/oam/v3alpha1/schema/platform/compose"
// 	v2alpha1k8s "jacero.io/oam/v3alpha1/schema/platform/kubernetes"
// )

#TraitTypes: string & "scaling" | "networking" | "storage" | "security" | "monitoring"

#Trait: {
	#apiVersion: "core.oam.dev/v3alpha1"
	#kind:       "Trait"

	#metadata: {
		name:       _
		namespace?: _
		annotations?: [string]: string | int | bool
		labels?: [string]:      string | int | bool

		labels?: "trait.oam.dev/name": #metadata.name
		labels?: "trait.oam.dev/type": #metadata.type

		annotations?: "trait.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the trait.
	#metadata: {
		type: #TraitTypes

		// A description of the trait.
		description?: string

		// What workload types this trait can be applied to.
		appliesTo: [...#Schema]
	}

	schema!: #Schema

	properties: {...}

}
