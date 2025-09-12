package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

// NetworkPolicy defines the properties and behaviors of a Kubernetes NetworkPolicy
#NetworkPolicy: core.#Trait & {
	#metadata: #traits: NetworkPolicy: core.#TraitMetaAtomic & {
		#kind:       "NetworkPolicy"
		description: "Kubernetes NetworkPolicy for controlling network traffic to and from pods"
		domain:      "security"
		scope: ["component"]
		provides: {networkpolicies: [string]: schema.#NetworkPolicySpec}
	}
	networkpolicies: [string]: schema.#NetworkPolicySpec
}

#NetworkPolicyMeta: #NetworkPolicy.#metadata.#traits.NetworkPolicy
