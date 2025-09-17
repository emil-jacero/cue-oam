package governance

import (
	core "jacero.io/oam/core/v2alpha2"
)

// Namespace - Creates a Kubernetes Namespace for resource isolation
#Namespace: core.#Trait & {
	#metadata: #traits: Namespace: core.#TraitMetaAtomic & {
		#apiVersion: "k8s.io/api/core/v1"
		#kind:       "Namespace"
		description: "Creates a Kubernetes Namespace for resource isolation and organization"
		domain:      "governance"
		scope: ["component"]
		provides: {namespace: #Namespace.namespace}
	}

	namespace: {
		name: string
		// Additional labels for the namespace
		labels?: [string]: string

		// Additional annotations for the namespace
		annotations?: [string]: string
	}
}

#NamespaceMeta: #Namespace.#metadata.#traits.Namespace
