package schema

//////////////////////////////////////////////
//// Trait schemas
//////////////////////////////////////////////

#ConfigSpec: {
	// Immutable, if true, ensures that data stored in the ConfigMap cannot be updated (only object metadata can be modified).
	immutable?: bool

	// Unencoded raw string data
	data: [string]: string
	// Base64 encoded data
	binaryData?: [string]: string
}

#SecretSpec: {
	// The type of the secret, used to determine how to interpret the data.
	// Default is "Opaque".
	type: string | *"Opaque" | "kubernetes.io/dockerconfigjson" | "kubernetes.io/ssh-auth" | "kubernetes.io/tls"
	// Base64 encoded data.
	// Must be encoded by the client beforehand
	data: [string]: string
	// Unencoded raw string data
	stringData?: [string]: string

	if type == "kubernetes.io/dockerconfigjson" {
		data: ".dockerconfigjson":        string
		stringData?: ".dockerconfigjson": string
	}
	if type == "kubernetes.io/ssh-auth" {
		data: "ssh-privatekey":        string
		stringData?: "ssh-privatekey": string
	}
	if type == "kubernetes.io/tls" {
		data: "tls.crt":        string
		data: "tls.key":        string
		stringData?: "tls.crt": string
		stringData?: "tls.key": string
	}
}
