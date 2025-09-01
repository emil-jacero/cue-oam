package trait

import (
	v2alpha2core "jacero.io/oam/v2alpha2/core"
	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
	v2alpha2compose "jacero.io/oam/v2alpha2/schema/compose"
)

#Labels: v2alpha2core.#Trait & {
	#metadata: {
		name:        "labels.traits.core.oam.dev"
		description: "A trait to add labels to a component's resources"
		attributes: {
			podDisruptive: true
		}
		appliesTo: ["*"]
	}

	#component: v2alpha2core.#Component

	properties: {
		[string]: string | null
	}

	template: {
		// Kubernetes resource template
		kubernetes: resources: [...v2alpha2k8s.#Object]
		kubernetes: resources: [for r in #component.template.kubernetes.resources {
			metadata: labels: {
				for k, v in properties {
					"\(k)": "\(v)"
				}
			}
		}]
		// Docker Compose template
		compose: services: close({{[=~"^[a-zA-Z0-9._-]+$"]: v2alpha2compose.#Service}})
		for ks, vs in #component.template.compose.services {
			compose: services: "\(ks)": labels: {
				for k, v in properties {
					"\(k)": "\(v)"
				}
			}
		}
	}
}
