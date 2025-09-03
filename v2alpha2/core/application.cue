package core

import (
	"strings"

	v2alpha2compose "jacero.io/oam/v2alpha2/schema/compose"
	v2alpha2k8s "jacero.io/oam/v2alpha2/schema/kubernetes"
)

#Application: #Object & {
	#apiVersion: "core.oam.dev/v2alpha2"
	#kind:       "Application"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "application.oam.dev/name": #metadata.name

		annotations: "application.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the application.
	#metadata: {
		description?: string & strings.MinRunes(1) & strings.MaxRunes(1024)
	}

	#components: [...#ApplicationComponent]

	// Inject ContextMeta so that it can be referenced in the component's template.
	for c in #components {
		#components: [c & {#context: #metadata}]
	}

	#template: {
		// Kubernetes
		kubernetes: resources: [...v2alpha2k8s.#Object]

		// Docker Compose
		compose: v2alpha2compose.#Compose

		for c in #components {
			// Add Kubernetes resources
			kubernetes: resources: c.template.kubernetes.resources

			// Add Docker Compose resources
			compose: c.template.compose

			// "Patch" with traits
			if c.traits != _|_ {
				for trait in c.traits {
					kubernetes: resources: (trait & {#component: c}).template.kubernetes.resources
					compose: (trait & {#component: c}).template.compose
				}
			}
		}
		...
	}
	kubernetes: #template.kubernetes.resources
	compose: #template.compose
}

#ApplicationComponent: #Component & {
	// The traits that are applied to this component.
	traits?: [...#Trait]

	// The scopes that this component is associated with.
	// Not yet implemented
	scopes?: [...#Scope]
}
