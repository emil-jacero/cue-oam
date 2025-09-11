package networking

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/kubernetes/schema"
)

#NetworkPolicyTrait: core.#TraitObject & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "NetworkPolicy"

	description: "Kubernetes NetworkPolicy for controlling network traffic to and from pods"

	type:   "atomic"
	domain: "security"
	scope: ["component"]

	requiredCapabilities: [
		"k8s.io/api/networking/v1.NetworkPolicy",
	]

	provides: {
		networkpolicy: schema.NetworkPolicy
	}
}
#NetworkPolicy: core.#Trait & {
	#metadata: #traits: NetworkPolicy: #NetworkPolicyTrait
	networkpolicy: schema.NetworkPolicy
}
