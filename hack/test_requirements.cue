package hack

import (
	"strconv"
	"strings"
)

// CPUQuantity is a string that is validated as a quantity of CPU.
// Allow either Kubernetes millicpu (e.g. "100m") or decimal cores (e.g. "0.1", "1", "2.5").
// Disallows zero ("0", "0.0"); requires a positive value.
#CPUQuantity: string & =~"^(?:[1-9][0-9]*m|(?:0\\.(?:0*[1-9][0-9]*)|[1-9][0-9]*(?:\\.[0-9]+)?))$"

// MemoryQuantity is a string that is validated as a quantity of memory, such as 128Mi or 2Gi.
#MemoryQuantity: string & =~"^[1-9]\\d*(Mi|Gi)$"

// ResourceRequirement defines the schema for the CPU and Memory resource requirements.
#ResourceRequirement: {
	cpu?:    #CPUQuantity
	memory?: #MemoryQuantity
}

// ResourceRequirements defines the schema for the compute resource requirements of a container.
// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/.
// TODO: Implement validation that Requests cannot exceed Limits.
#ResourceRequirements: {
	// Limits describes the maximum amount of compute resources allowed.
	limits?: #ResourceRequirement

	// Requests describes the minimum amount of compute resources required.
	// Requests cannot exceed Limits.
	requests?: #ResourceRequirement & {
		if limits != _|_ {
			if limits.cpu != _|_ {
                _limitCpu:  float32
                _requestCpu: float32

                if strings.HasSuffix(limits.cpu, "m") {_limitCpu: strconv.ParseFloat(strings.TrimSuffix(limits.cpu, "m"), 2)}
                if strings.HasSuffix(requests.cpu, "m") {_requestCpu: strconv.ParseFloat(strings.TrimSuffix(requests.cpu, "m"), 2)}
                if !strings.HasSuffix(limits.cpu, "m") {_limitCpu: strconv.ParseFloat(limits.cpu, 2) * 1000}
                if !strings.HasSuffix(requests.cpu, "m") {_requestCpu: strconv.ParseFloat(requests.cpu, 2) * 1000}
                #cpu: float32 & >=_requestCpu & _limitCpu
			}
		}
        if limits != _|_ {
            if limits.memory != _|_ {
                _limitMemory: int
                _requestMemory: int

                if strings.HasSuffix(limits.memory, "Mi") {_limitMemory: strconv.Atoi(strings.TrimSuffix(limits.memory, "Mi"))}
                if strings.HasSuffix(requests.memory, "Mi") {_requestMemory: strconv.Atoi(strings.TrimSuffix(requests.memory, "Mi"))}
                if strings.HasSuffix(limits.memory, "Gi") {_limitMemory: strconv.Atoi(strings.TrimSuffix(limits.memory, "Gi")) * 1024}
                if strings.HasSuffix(requests.memory, "Gi") {_requestMemory: strconv.Atoi(strings.TrimSuffix(requests.memory, "Gi")) * 1024}

                #memory: int & >=_requestMemory & _limitMemory
            }
        }
	}
}

test: #ResourceRequirements
test: {
    limits: {
        cpu:    "100m"
        memory: "1Gi"
    }
    requests: {
        cpu:    "0.1"
        memory: "128Mi"
    }
}