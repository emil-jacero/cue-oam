package compose

import (
	"strconv"
	"strings"

	// v2alpha1core "jacero.io/oam/v2alpha1/core"
)

#QuantityToCompose: {
	input:  string
	output: #Quantity
	if strings.HasSuffix(input, "Ki") {output: "\(strings.TrimSuffix(input, "Ki"))k"}
	if strings.HasSuffix(input, "Mi") {output: "\(strings.TrimSuffix(input, "Mi"))m"}
	if strings.HasSuffix(input, "Gi") {output: "\(strings.TrimSuffix(input, "Gi"))g"}
	if strings.HasSuffix(input, "Ti") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)g"}
	if strings.HasSuffix(input, "Pi") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)g"}
	if strings.HasSuffix(input, "Ei") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)g"}
	outputLong: #Quantity
	if strings.HasSuffix(input, "Ki") {outputLong: "\(strings.TrimSuffix(input, "Ki"))kb"}
	if strings.HasSuffix(input, "Mi") {outputLong: "\(strings.TrimSuffix(input, "Mi"))mb"}
	if strings.HasSuffix(input, "Gi") {outputLong: "\(strings.TrimSuffix(input, "Gi"))gb"}
	if strings.HasSuffix(input, "Ti") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)gb"}
	if strings.HasSuffix(input, "Pi") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)gb"}
	if strings.HasSuffix(input, "Ei") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)gb"}
}

// ComposeQuantity is a string that is validated as a quantity for Docker Compose resource limits and reservations.
// Valid units are: k, m, g, kb, mb, gb (case insensitive).
// More info: https://docs.docker.com/reference/compose-file/deploy/#resources
// More info: https://docs.docker.com/reference/compose-file/extension/#specifying-byte-values
#Quantity: string & =~"^[1-9]\\d*(k|m|g|kb|mb|gb)?$"

// MemoryToCompose converts Kubernetes-style memory quantities (e.g. "128Mi", "2Gi") to Docker Compose-style quantities (e.g. "128m", "2g").
#K8sMemoryToCompose: {
	input:  string
	output: #Quantity
	if strings.HasSuffix(input, "Ki") {output: "\(strings.TrimSuffix(input, "Ki"))k"}
	if strings.HasSuffix(input, "Mi") {output: "\(strings.TrimSuffix(input, "Mi"))m"}
	if strings.HasSuffix(input, "Gi") {output: "\(strings.TrimSuffix(input, "Gi"))g"}
	if strings.HasSuffix(input, "Ti") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)g"}
	if strings.HasSuffix(input, "Pi") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)g"}
	if strings.HasSuffix(input, "Ei") {output: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)g"}
	outputLong: #Quantity
	if strings.HasSuffix(input, "Ki") {outputLong: "\(strings.TrimSuffix(input, "Ki"))kb"}
	if strings.HasSuffix(input, "Mi") {outputLong: "\(strings.TrimSuffix(input, "Mi"))mb"}
	if strings.HasSuffix(input, "Gi") {outputLong: "\(strings.TrimSuffix(input, "Gi"))gb"}
	if strings.HasSuffix(input, "Ti") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ti"))*1024)gb"}
	if strings.HasSuffix(input, "Pi") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Pi"))*1024*1024)gb"}
	if strings.HasSuffix(input, "Ei") {outputLong: "\(strconv.Atoi(strings.TrimSuffix(input, "Ei"))*1024*1024*1024)gb"}
}

// MemoryQuantity is a string that is validated as a quantity of memory, such as 128m, 128mb or 2g.
// Valid units are: k, m, g, kb, mb, gb (case insensitive).
// More info: https://docs.docker.com/reference/compose-file/deploy/#resources
// More info: https://docs.docker.com/reference/compose-file/extension/#specifying-byte-values
#MemoryQuantity: string & =~"^[1-9]\\d*(k|m|g|kb|mb|gb)?$"

// Convert "100m", "250m", 0.5, 1 -> "0.1", "0.25", "0.5", "1"
#CPUToCompose: {
	input: string

	// Final output guaranteed to be a decimal-cores string
	output: string & #ComposeCpus

	// mCPU -> cores
	if strings.HasSuffix(input, "m") {
		_m:  int & strconv.Atoi(strings.TrimSuffix(input, "m"))
		output:  "\(_m/1000.0)"
	}

	// plain int/float string or numeric -> pass through normalized
	if !strings.HasSuffix(input, "m") {
		output: "\(strconv.ParseFloat(input, 2))"
	}
}


// Decimal cores string for Compose deploy.resources.*.cpus
#ComposeCpus: =~"^[0-9]+(\\.[0-9]+)?$"
