package core

import (
	"strings"

	v2alpha1compose "jacero.io/oam/v3alpha1/schema/platform/compose"
	v2alpha1k8s "jacero.io/oam/v3alpha1/schema/platform/kubernetes"
)

#Module: #Object & {
	#apiVersion: "core.oam.dev/v3alpha1"
	#kind:       "Module"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "module.oam.dev/name": #metadata.name
		labels: "module.oam.dev/type": #metadata.type

		// A description of the module, used for documentation
		annotations: "module.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the module.
	#metadata: {
		// A description of the module.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(1024)
	}

	components: [...#ModuleComponent]

	template: {
		// Kubernetes
		kubernetes: resources: [...v2alpha1k8s.#Object]
		// Docker Compose
		compose: v2alpha1compose.#Compose
		for component in components {
			kubernetes: resources: component.template.kubernetes.resources
			compose: component.template.compose
		}
		...
	}
}

#ModuleComponent: #Component & {
	// The traits that are applied to this component.
	traits?: [...#Trait]

	// The scopes that this component is associated with.
	// scopes?: [...#Scope]
}
