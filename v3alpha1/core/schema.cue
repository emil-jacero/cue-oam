package core

import (
	"strings"
)

#SchemaTypes:        string & "*" | #GenericSchemaTypes | #K8sSchemaTypes
#GenericSchemaTypes: string & "server" | "worker" | "task" | "database"
#K8sSchemaTypes:     string & "deployments.apps" | "statefulsets.apps" | "daemonsets.apps" | "jobs.batch" | "cronjobs.batch"

#Schema: #Object & {
	#apiVersion: "core.oam.dev/v3alpha1"
	#kind:       "Schema"

	#metadata: {
		name:         _
		namespace?:   _
		labels?:      _
		annotations?: _

		labels: "schema.oam.dev/name": #metadata.name
		labels: "schema.oam.dev/type": #metadata.type

		// A description of the schema, used for documentation
		annotations: "schema.oam.dev/description": #metadata.description
	}

	// Extended metadata and attributes for the schema.
	#metadata: {
		type: #SchemaTypes

		// A description of the schema.
		description?: string & strings.MinRunes(1) & strings.MaxRunes(1024)
	}

	schema: {...}
}
