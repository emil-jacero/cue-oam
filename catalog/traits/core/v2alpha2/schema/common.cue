package schema

import (
	"strconv"
	"strings"
)

// ImageTemplate defines the schema for OCI image reference used in Kubernetes PodSpec container image.
#ImageTemplate: #ImageSchema & {
	repository!: _
	tag!: _
	digest!: _
	pullPolicy: _
	reference: string

	if digest != "" && tag != "" {
		reference: "\(repository):\(tag)@\(digest)"
	}

	if digest != "" && tag == "" {
		reference: "\(repository)@\(digest)"
	}

	if digest == "" && tag != "" {
		reference: "\(repository):\(tag)"
	}

	if digest == "" && tag == "" {
		reference: "\(repository):latest"
	}
}

// ImageSchema defines the schema for OCI image reference used in Kubernetes PodSpec container image.
#ImageSchema: {
	// Repository is the address of a container registry repository.
	// An image repository is made up of slash-separated name components, optionally
	// prefixed by a registry hostname and port in the format [HOST[:PORT_NUMBER]/]PATH.
	repository!: string

	// Tag identifies an image in the repository.
	// A tag name may contain lowercase and uppercase characters, digits, underscores, periods and dashes.
	// A tag name may not start with a period or a dash and may contain a maximum of 128 characters.
	tag!: string & strings.MaxRunes(128)

	// Digest uniquely and immutably identifies an image in the repository.
	// Spec: https://github.com/opencontainers/image-spec/blob/main/descriptor.md#digests.
	digest!: string

	// PullPolicy defines the pull policy for the image.
	// By default, it is set to IfNotPresent.
	pullPolicy: #PullPolicy | *"IfNotPresent"

	// Reference is the image address computed from repository, tag and digest
	// in the format [REPOSITORY]:[TAG]@[DIGEST].
	reference: string
}

#PullPolicy: string & "IfNotPresent" | "Always" | "Never"

// Validates k8s-style resource quantities (e.g. "1Gi", "500Mi").
#StorageQuantity: =~"^[0-9]+(\\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei)?$"

// CPUQuantity is a string that is validated as a quantity of CPU.
// Allow either Kubernetes millicpu (e.g. "100m") or decimal cores (e.g. "0.1", "1", "2.5").
// Disallows zero ("0", "0.0"); requires a positive value.
#CPUQuantity: string & =~"^(?:[1-9][0-9]*m|(?:0\\.(?:0*[1-9][0-9]*)|[1-9][0-9]*(?:\\.[0-9]+)?))$"

// MemoryQuantity is a string that is validated as a quantity of memory, such as 128Mi or 2Gi.
#MemoryQuantity: string & =~"^[1-9]\\d*(Mi|Gi)$"

// GPUQuantity is a string that is validated as a quantity of GPU, such as 1 or 2.
#GPUQuantity: string & =~"^[1-9]\\d*$"

// ResourceRequirement defines the schema for the CPU and Memory resource requirements.
#ResourceRequirement: {
	cpu?:    #CPUQuantity
	memory?: #MemoryQuantity
	gpu?:    #GPUQuantity
}

// ResourceRequirements defines the schema for the compute resource requirements of a container.
// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/.
#ResourceRequirements: {
	// Limits describes the maximum amount of compute resources allowed.
	limits?: #ResourceRequirement

	// Requests describes the minimum amount of compute resources required.
	// Requests cannot exceed Limits.
	requests?: #ResourceRequirement & {
		if limits != _|_ {
			if limits.cpu != _|_ {
				_limitCpu:   float32
				_requestCpu: float32

				if strings.HasSuffix(limits.cpu, "m") {_limitCpu: strconv.ParseFloat(strings.TrimSuffix(limits.cpu, "m"), 2)}
				if strings.HasSuffix(requests.cpu, "m") {_requestCpu: strconv.ParseFloat(strings.TrimSuffix(requests.cpu, "m"), 2)}
				if !strings.HasSuffix(limits.cpu, "m") {_limitCpu: strconv.ParseFloat(limits.cpu, 2) * 1000}
				if !strings.HasSuffix(requests.cpu, "m") {_requestCpu: strconv.ParseFloat(requests.cpu, 2) * 1000}
				#cpu: float32 & >=_requestCpu & _limitCpu
			}
			if limits.memory != _|_ {
				_limitMemory:   int
				_requestMemory: int

				if strings.HasSuffix(limits.memory, "Mi") {_limitMemory: strconv.Atoi(strings.TrimSuffix(limits.memory, "Mi"))}
				if strings.HasSuffix(requests.memory, "Mi") {_requestMemory: strconv.Atoi(strings.TrimSuffix(requests.memory, "Mi"))}
				if strings.HasSuffix(limits.memory, "Gi") {_limitMemory: strconv.Atoi(strings.TrimSuffix(limits.memory, "Gi")) * 1024}
				if strings.HasSuffix(requests.memory, "Gi") {_requestMemory: strconv.Atoi(strings.TrimSuffix(requests.memory, "Gi")) * 1024}

				#memory: int & >=_requestMemory & _limitMemory
			}
		}
	}

	// Resource claims (K8s 1.31+)
	resourceClaims?: [...{
		name: string
		source: {
			resourceClaimName?:         string
			resourceClaimTemplateName?: string
		}
	}]
}
