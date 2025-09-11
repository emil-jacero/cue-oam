package structural

import (
	core "jacero.io/oam/core/v2alpha2"
)

// NamespaceIsolationScope - Enforces namespace boundaries and isolation for all components within the scope
#NamespaceIsolationScopeTraitMeta: #NamespaceIsolationScope.#metadata.#traits.NamespaceIsolationScope

#NamespaceIsolationScope: core.#Trait & {
	#metadata: #traits: NamespaceIsolationScope: core.#TraitMetaAtomic & {
		#kind:       "NamespaceIsolationScope"
		description: "Enforces namespace boundaries and isolation for all components within the scope"
		domain:      "structural"
		scope: ["scope"]
		provides: {namespaceIsolation: #NamespaceIsolationScope.namespaceIsolation}
	}

	namespaceIsolation: {
		// The namespace to isolate components in
		namespace: string

		// Isolation level
		isolationLevel: "strict" | "relaxed" | *"strict"

		// Cross-namespace communication rules
		crossNamespaceRules?: {
			// Allow ingress from specific namespaces
			allowIngressFrom?: [...string]

			// Allow egress to specific namespaces
			allowEgressTo?: [...string]

			// Block all cross-namespace traffic
			blockAll?: bool | *false
		}

		// Labels to apply to the namespace
		labels?: {[string]: string}

		// Annotations to apply to the namespace
		annotations?: {[string]: string}
	}
}