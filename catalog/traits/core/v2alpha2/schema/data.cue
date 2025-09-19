package schema

//////////////////////////////////////////////
//// Trait schemas
//////////////////////////////////////////////

// OpenAPIv3 compatible schema for a config
#ConfigSpec: {
	// Immutable, if true, ensures that data stored in the ConfigMap cannot be updated (only object metadata can be modified).
	immutable?: bool

	// Unencoded raw string data
	data: [string]: string
	// Base64 encoded data
	binaryData?: [string]: string
}

// OpenAPIv3 compatible schema for a secret
#SecretSpec: {
	// The type of the secret, used to determine how to interpret the data.
	// Default is "Opaque".
	type: string | *"Opaque" | "kubernetes.io/dockerconfigjson" | "kubernetes.io/ssh-auth" | "kubernetes.io/tls"
	// Base64 encoded data.
	// Must be encoded by the client beforehand
	data: [string]: string
	// Unencoded raw string data
	stringData?: [string]: string
}
