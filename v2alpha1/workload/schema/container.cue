package schema

import (
	"strings"

	// v2alpha1core "jacero.io/oam/v2alpha1/core"
)

#ContainerSpec: {
	name:  string & strings.MaxRunes(254)
	image: #Image
	command?: [...string]
	args?: [...string]
	// Container's working directory. If not specified, the container runtime's default will be used,
	// which might be configured in the container image. Cannot be updated.
	workingDir?: string & strings.MaxRunes(1024)
	// List of environment variables to set in the container.
	env?: [...#EnvVar]

	// Ports to expose from the container.
	// Each port must have a unique name within the container.
	// If a port is not specified, the container runtime's default will be used.
	ports?: [...#Port]

	// Volumes that can be mounted into the container.
	// A volume specified here will also create the the relevant volume for the workload.
	volumes?: [...#Volume]

	// Resources required by the container.
	// Requests describes the minimum amount of compute resources required.
	// If Requests is omitted for a container, it defaults to an implementation-defined value.
	// Limits describes the maximum amount of compute resources allowed.
	// If Limits is omitted for a container, it defaults to an implementation-defined value.
	// Requests cannot exceed Limits.
	resources?: #ResourceRequirements

	// securityContext?: {}

	lifecycle?: {
		postStart?:  #LifecycleHandler
		preStop?:    #LifecycleHandler
		stopSignal?: #Signal
	}

	// Instructions for assessing whether the container is alive.
	livenessProbe?: [string]: #HealthProbe

	// Instructions for assessing whether the container is in a
	// suitable state to serve traffic.
	readinessProbe?: [string]: #HealthProbe

	// StartupProbe indicates that the Pod has successfully initialized.
	// If specified, no other probes are executed until this completes successfully.
	// If this probe fails, the Pod will be restarted, just as if the livenessProbe failed.
	// This can be used to provide different probe parameters at the beginning of a Pod's lifecycle,
	//when it might take a long time to load data or warm a cache, than during steady-state operation. This cannot be updated.
	startupProbe?: [string]: #HealthProbe

	// Whether this container should allocate a buffer for stdin in the container runtime.
	// If this is not set, reads from stdin in the container will always result in EOF. Default is false.
	stdin?: bool | *false

	// Whether the container runtime should close the stdin channel after it has been opened by a single attach.
	// When stdin is true the stdin stream will remain open across multiple attach sessions.
	// If stdinOnce is set to true, stdin is opened on container start,
	// is empty until the first client attaches to stdin, and then remains open and accepts data until the client disconnects,
	// at which time stdin is closed and remains closed until the container is restarted.
	// If this flag is false, a container processes that reads from stdin will never receive an EOF. Default is false
	stdinOnce?: bool | *false

	// Optional: Path at which the file to which the container's termination message will be written is mounted into the container's filesystem.
	// Message written is intended to be brief final status, such as an assertion failure message.
	// Will be truncated by the node if greater than 4096 bytes. The total message length across all containers will be limited to 12kb.
	// Defaults to /dev/termination-log. Cannot be updated.
	terminationMessagePath?: string | *"/dev/termination-log"

	// Indicate how the termination message should be populated. File will use the contents of terminationMessagePath to populate the container
	// status message on both success and failure. FallbackToLogsOnError will use the last chunk of container log output if
	// the termination message file is empty and the container exited with an error. The log output is limited to 2048 bytes or 80 lines,
	// whichever is smaller. Defaults to File. Cannot be updated. 
	terminationMessagePolicy?: *"File" | "FallbackToLogsOnError"

	// Whether this container should allocate a TTY for itself, also requires 'stdin' to be true. Default is false.
	tty?: bool | *false
	...
}

#EnvVarSource: {
	// Selects a key of a ConfigMap.
	configMapKeyRef?: {
		name?:     string
		key:       string & strings.MaxRunes(63)
		optional?: bool
	}
	// Selects a key of a secret in the pod's namespace
	secretKeyRef?: {
		name?:     string
		key:       string & strings.MaxRunes(63)
		optional?: bool
	}
	// Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`,
	// `metadata.annotations['<KEY>']`, spec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.
	fieldRef?: {
		apiVersion?: string
		fieldPath:   string & strings.MaxRunes(1024)
	}
	// Selects a resource of the container: only resources limits and requests (limits.cpu, limits.memory,
	// limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.
	resourceFieldRef?: {
		containerName?: string
		divisor:        #StorageQuantity
		resource:       string & strings.MaxRunes(63)
	}
}

#EnvVar: {
	name:   string & strings.MaxRunes(63)
	value?: string & strings.MaxRunes(1024)
	// valueFrom?: #EnvVarSource
}

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

// Signal is a signal that can be sent to a process.
#Signal: "SIGABRT" | "SIGALRM" | "SIGBUS" | "SIGCHLD" | "SIGCLD" | "SIGCONT" | "SIGFPE" | "SIGHUP" | "SIGILL" | "SIGINT" | "SIGIO" | "SIGIOT" | "SIGKILL" | "SIGPIPE" | "SIGPOLL" | "SIGPROF" | "SIGPWR" | "SIGQUIT" | "SIGSEGV" | "SIGSTKFLT" | "SIGSTOP" | "SIGSYS" | "SIGTERM" | "SIGTRAP" | "SIGTSTP" | "SIGTTIN" | "SIGTTOU" | "SIGURG" | "SIGUSR1" | "SIGUSR2" | "SIGVTALRM" | "SIGWINCH" | "SIGXCPU" | "SIGXFSZ" | "SIGRTMIN" | "SIGRTMIN+1" | "SIGRTMIN+2" | "SIGRTMIN+3" | "SIGRTMIN+4" | "SIGRTMIN+5" | "SIGRTMIN+6" | "SIGRTMIN+7" | "SIGRTMIN+8" | "SIGRTMIN+9" | "SIGRTMIN+10" | "SIGRTMIN+11" | "SIGRTMIN+12" | "SIGRTMIN+13" | "SIGRTMIN+14" | "SIGRTMIN+15" | "SIGRTMAX-14" | "SIGRTMAX-13" | "SIGRTMAX-12" | "SIGRTMAX-11" | "SIGRTMAX-10" | "SIGRTMAX-9" | "SIGRTMAX-8" | "SIGRTMAX-7" | "SIGRTMAX-6" | "SIGRTMAX-5" | "SIGRTMAX-4" | "SIGRTMAX-3" | "SIGRTMAX-2" | "SIGRTMAX-1" | "SIGRTMAX"

// RestartPolicy defines the restart policy for the workload.
#RestartPolicy: string | *"Always" | "OnFailure" | "Never"

// RestartPolicyToDockerMap is a mapping of the restart policy to the Docker Compose equivalent.
#RestartPolicyToDockerMap: {
	"Always":    "any"
	"OnFailure": "on-failure"
	"Never":     "none"
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

	// Instructions for assessing container health by executing an
	// HTTP GET request. Either this attribute or the exec attribute
	// or the tcpSocket attribute MUST be specified. This attribute
	// is mutually exclusive with both the exec attribute and the
	// tcpSocket attribute.
	httpGet?: close({
		// The endpoint, relative to the port, to which the HTTP GET
		// request should be directed.
		path: string

		// The TCP socket within the container to which the HTTP GET
		// request should be directed.
		port: int

		// Optional HTTP headers.
		httpHeaders?: close({
			// An HTTP header name. This must be unique per HTTP GET-based
			// probe.
			name: string

			// An HTTP header value.
			value: string
		})
	})

	// Instructions for assessing container health by probing a TCP
	// socket. Either this attribute or the exec attribute or the
	// httpGet attribute MUST be specified. This attribute is
	// mutually exclusive with both the exec attribute and the
	// httpGet attribute.
	tcpSocket?: close({
		// The TCP socket within the container that should be probed to
		// assess container health.
		port: int
	})

	// Number of seconds after the container is started before the
	// first probe is initiated.
	initialDelaySeconds?: int

	// How often, in seconds, to execute the probe.
	periodSeconds?: int

	// Number of seconds after which the probe times out.
	timeoutSeconds?: int

	// Minimum consecutive successes for the probe to be considered
	// successful after having failed.
	successThreshold?: int

	// Number of consecutive failures required to determine the
	// container is not alive (liveness probe) or not ready
	// (readiness probe).
	failureThreshold?: int
	...
}
