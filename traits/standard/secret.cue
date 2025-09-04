package standard

import (
	corev3 "jacero.io/oam/core/v3alpha1"
)

// Secret trait definition
#Secret: corev3.#Trait & {
	#metadata: #traits: Secret: {
		provides: {secrets: #Secret.secrets}
		requires: [
			"core.oam.dev/v3alpha1.Secret",
		]
		description: "Describes a set of secrets"
	}

	// Secrets to be created
	secrets: [string]: #SecretSpec
}

#ImagePullSecret: corev3.#Trait & {
	#metadata: #traits: ImagePullSecret: {
		provides: {imagePullSecrets: #ImagePullSecret.imagePullSecrets}
		requires: [
			"core.oam.dev/v3alpha1.ImagePullSecret",
		]
		extends: [#Secret.#metadata.Secret]
		description: "Describes a set of image pull secrets"
	}

	// Image pull secrets to be created
	I=imagePullSecret: {
		provider:        "aws"
		region:          string
		accessKey:       #Secret
		secretAccessKey: #Secret
	}
	secrets: imagePullSecret: I
}

// Register the trait
#Registry: corev3.#TraitRegistry & {
	traits: {
		"Secret":          #Secret
		"ImagePullSecret": #ImagePullSecret
	}
}
