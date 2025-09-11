package structural

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/core/v2alpha2/schema"
)

// Expose - Marks a component as exposable for external access
#ExposeTraitMeta: #Expose.#metadata.#traits.Expose

#Expose: core.#Trait & {
	#metadata: #traits: Expose: core.#TraitMetaAtomic & {
		#kind:       "Expose"
		description: "Marks a component as exposable for external access"
		domain:      "structural"
		scope: ["component"]
		provides: {expose: #Expose.expose}
	}

	expose: {
		// Type of service to create
		type: "LoadBalancer" | "NodePort" | "ClusterIP" | *"ClusterIP"
		// Port mappings
		ports: [...schema.#Port]
	}
}