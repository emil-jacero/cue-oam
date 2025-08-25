package schema

import (
	"strings"

	v2alpha1core "jacero.io/oam/v2alpha1/core"
)

#Secret: v2alpha1core.#Object & {
    apiVersion: "schema.oam.dev/v2alpha1"
    kind: "Secret"
    // The type of the secret, used to determine how to interpret the data.
    // Default is "Opaque".
    type: string | *"Opaque" | "kubernetes.io/dockerconfigjson" | "kubernetes.io/ssh-auth" | "kubernetes.io/tls"
    data: [string]: string // base64 encoded data
    stringData?: [string]: string // unencoded data
    if type == "kubernetes.io/dockerconfigjson" {
        data: ".dockerconfigjson": string
        stringData?: ".dockerconfigjson": string
    }
    if type == "kubernetes.io/ssh-auth" {
        data: "ssh-privatekey": string
        stringData?: "ssh-privatekey": string
    }
    if type == "kubernetes.io/tls" {
        data: "tls.crt": string
        data: "tls.key": string
        stringData?: "tls.crt": string
        stringData?: "tls.key": string
    }
}
