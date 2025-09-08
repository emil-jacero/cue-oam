package schema

import (
	"strings"
)

//////////////////////////////////////////////
//// Trait schemas
//////////////////////////////////////////////

#ContainerSpec: {
	// The name of the container.
	name: string & strings.MinRunes(1) & strings.MaxRunes(253)

	// The container image to use.
	image: #Image & {
		repository: _ | *""
		tag:        _ | *""
		digest:     _ | *""
	}

	// Secrets to use when pulling the container image.
	imagePullSecrets?: [...#SecretSpec]

	// Command to run in the container.
	command?: [...string]

	// Arguments to pass to the command.
	args?: [...string]

	// Container's working directory. If not specified, the container runtime's default will be used,
	// which might be configured in the container image. Cannot be updated.
	workingDir?: string & strings.MaxRunes(1024)

	// List of environment variables to set in the container.
	env?: [...#EnvVar]

	// Resources required by the container.
	// Requests describes the minimum amount of compute resources required.
	// If Requests is omitted for a container, it defaults to an implementation-defined value.
	// Limits describes the maximum amount of compute resources allowed.
	// If Limits is omitted for a container, it defaults to an implementation-defined value.
	// Requests cannot exceed Limits.
	resources?: #ResourceRequirements

	// Each port must have a unique name within the container.
	// If a port is not specified, the container runtime's default will be used.
	ports?: [...#Port]

	// Volumes that can be mounted into the container.
	// The volume can be defined here or passed in here from another definition inheriting from #Volume.
	volumeMounts?: [...#VolumeMount]

	restartPolicy?: #RestartPolicy

	// Instructions for assessing whether the container is alive.
	livenessProbe?: #HealthProbe

	// Instructions for assessing whether the container is in a
	// suitable state to serve traffic.
	readinessProbe?: #HealthProbe

	// StartupProbe indicates that the Pod has successfully initialized.
	// If specified, no other probes are executed until this completes successfully.
	// If this probe fails, the Pod will be restarted, just as if the livenessProbe failed.
	// This can be used to provide different probe parameters at the beginning of a Pod's lifecycle,
	//when it might take a long time to load data or warm a cache, than during steady-state operation. This cannot be updated.
	startupProbe?: #HealthProbe
}

// Defines an environment variable
#EnvVar: {
	name:       string
	value:      string
	valueFrom?: #EnvFromSource
}

// EnvVarSource represents a source for environment variables.
// For example, a secret or config map key.
// TODO: Add support for targeting specific fields in a resource or remapping keys.
#EnvFromSource: {
	// Selects a key of a ConfigMap.
	config?: #ConfigSpec
	// Selects a key of a secret in the pod's namespace
	secret?: #SecretSpec
	// An optional identifier to prepend to each key in the ConfigMap.
	prefix?: string
}

// RestartPolicy defines the restart policy for the workload.
#RestartPolicy: string | *"Always" | "OnFailure" | "Never"

// Signal is a signal that can be sent to a process.
#Signal: "SIGABRT" | "SIGALRM" | "SIGBUS" | "SIGCHLD" | "SIGCLD" | "SIGCONT" | "SIGFPE" | "SIGHUP" | "SIGILL" | "SIGINT" | "SIGIO" | "SIGIOT" | "SIGKILL" | "SIGPIPE" | "SIGPOLL" | "SIGPROF" | "SIGPWR" | "SIGQUIT" | "SIGSEGV" | "SIGSTKFLT" | "SIGSTOP" | "SIGSYS" | "SIGTERM" | "SIGTRAP" | "SIGTSTP" | "SIGTTIN" | "SIGTTOU" | "SIGURG" | "SIGUSR1" | "SIGUSR2" | "SIGVTALRM" | "SIGWINCH" | "SIGXCPU" | "SIGXFSZ" | "SIGRTMIN" | "SIGRTMIN+1" | "SIGRTMIN+2" | "SIGRTMIN+3" | "SIGRTMIN+4" | "SIGRTMIN+5" | "SIGRTMIN+6" | "SIGRTMIN+7" | "SIGRTMIN+8" | "SIGRTMIN+9" | "SIGRTMIN+10" | "SIGRTMIN+11" | "SIGRTMIN+12" | "SIGRTMIN+13" | "SIGRTMIN+14" | "SIGRTMIN+15" | "SIGRTMAX-14" | "SIGRTMAX-13" | "SIGRTMAX-12" | "SIGRTMAX-11" | "SIGRTMAX-10" | "SIGRTMAX-9" | "SIGRTMAX-8" | "SIGRTMAX-7" | "SIGRTMAX-6" | "SIGRTMAX-5" | "SIGRTMAX-4" | "SIGRTMAX-3" | "SIGRTMAX-2" | "SIGRTMAX-1" | "SIGRTMAX"

// LifecycleHandler defines a specific action that should be taken in a lifecycle event of a container.
#LifecycleHandler: {
	exec?: {
		// The command to run in the container, e.g. ["nginx", "-g", "daemon off;"]
		command: [...string] & strings.MaxRunes(1024)
	}
	httpGet?: {
		// Host name to connect to, defaults to the pod IP. You probably want to set "Host" in httpHeaders instead.
		host?: string & =~"^((\\d{1,3}\\.){3}\\d{1,3}|\\[([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\\])$"
		// Path to access on the HTTP server.
		path?: string & strings.MaxRunes(1024)
		// Name or number of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
		port: uint & >=0
		// Scheme to use for connecting to the host. Defaults to HTTP. 
		scheme?: *"HTTP" | "TCP" | "GRPC" | "GRPCS"
		// Custom headers to set in the request. HTTP allows repeated headers.
		httpHeaders?: [...{
			name:  string & strings.MaxRunes(63)
			value: string & strings.MaxRunes(1024)
		}]
	}
	tcpSocket?: {
		// Optional: Host name to connect to, defaults to the pod IP.
		host?: string & =~"^((\\d{1,3}\\.){3}\\d{1,3}|\\[([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\\])$"
		// Number or name of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
		port: uint & >=0
	}
}

// Health Probe describes how a probing operation is to be
// executed as a way of determining the health of a component.
#HealthProbe: {
	// Instructions for assessing container health by executing a
	// command. Either this attribute or the httpGet attribute or the
	// tcpSocket attribute MUST be specified. This attribute is
	// mutually exclusive with both the httpGet attribute and the
	// tcpSocket attribute.
	exec?: {
		// A command to be executed inside the container to assess its
		// health. Each space delimited token of the command is a
		// separate array element. Commands exiting 0 are considered to
		// be successful probes, whilst all other exit codes are
		// considered failures.
		command?: string
		...
	}

	// GRPC specifies a GRPC HealthCheckRequest. 
	grpc?: {
		// Port number of the gRPC service. Number must be in the range 1 to 65535. 
		port!: uint

		// Service is the name of the service to place in the gRPC HealthCheckRequest
		// (see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).
		// If this is not specified, the default behavior is defined by gRPC.
		service?: string
	}

	// Instructions for assessing container health by executing an
	// HTTP GET request. Either this attribute or the exec attribute
	// or the tcpSocket attribute MUST be specified. This attribute
	// is mutually exclusive with both the exec attribute and the
	// tcpSocket attribute.
	httpGet?: {
		// Host name to connect to, defaults to the pod IP.
		// You probably want to set "Host" in httpHeaders instead.
		host?: string

		// Custom headers to set in the request. HTTP allows repeated headers.
		httpHeaders?: [...#HTTPHeader]

		// Path to access on the HTTP server.
		path?: string

		// Name or number of the port to access on the container.
		// Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.
		port!: uint

		// Scheme to use for connecting to the host. Defaults to HTTP.
		scheme?: string
	}

	// Instructions for assessing container health by probing a TCP
	// socket. Either this attribute or the exec attribute or the
	// httpGet attribute MUST be specified. This attribute is
	// mutually exclusive with both the exec attribute and the
	// httpGet attribute.
	tcpSocket?: {
		// Optional: Host name to connect to, defaults to the pod IP.
		host?: string

		// The TCP socket within the container that should be probed to
		// assess container health.
		port!: uint
	}

	// Number of seconds after the container has started before liveness probes are initiated.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	initialDelaySeconds?: int32

	// How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1. 
	periodSeconds?: int32 & >=1 | *10

	// Number of seconds after which the probe times out.
	// Defaults to 1 second. Minimum value is 1.
	// More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
	timeoutSeconds?: int32 & >=1 | *1

	// Minimum consecutive successes for the probe to be considered successful after having failed.
	// Defaults to 1. Must be 1 for liveness and startup. Minimum value is 1.
	successThreshold?: int32 & >=1 | *1

	// Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1..
	failureThreshold?: int32 & >=1 | *3

	// Optional duration in seconds the pod needs to terminate gracefully upon probe failure.
	// The grace period is the duration in seconds after the processes running in the pod are sent a termination signal
	// and the time when the processes are forcibly halted with a kill signal.
	//
	// Set this value longer than the expected cleanup time for your process.
	// If this value is nil, the pod's terminationGracePeriodSeconds will be used.
	// Otherwise, this value overrides the value provided by the pod spec. Value must be non-negative integer.
	// The value zero indicates stop immediately via the kill signal (no opportunity to shut down).
	// This is a beta field and requires enabling ProbeTerminationGracePeriod feature gate.
	// Minimum value is 1. spec.terminationGracePeriodSeconds is used if unset.
	terminationGracePeriodSeconds?: uint
}

// HTTPHeader describes a custom header to be used in HTTP probes 
#HTTPHeader: {
	name!:  string
	value!: string
}
