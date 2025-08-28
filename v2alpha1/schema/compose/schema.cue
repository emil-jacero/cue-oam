// Compose Specification
//
// The Compose file is a YAML file defining a multi-containers
// based application.
package compose

import "list"

@jsonschema(schema="https://json-schema.org/draft/2020-12/schema")

#Compose: {
	// define the Compose project name, until user defines one explicitly.
	name?: string

	// compose sub-projects to be included.
	include?: [...#Include]

	// The services that will be used by your application.
	services?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #Service}
	})

	// Networks that are shared among multiple services.
	networks?: {
		{[=~"^[a-zA-Z0-9._-]+$"]: #Network}
		...
	}

	// Named volumes that are shared among multiple services.
	volumes?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #Volume}
	})

	// Secrets that are shared among multiple services.
	secrets?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #Secret}
	})

	// Configurations that are shared among multiple services.
	configs?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #Config}
	})
}

// Block IO limit for a specific device.
#blkio_limit: close({
	// Path to the device (e.g., '/dev/sda').
	path?: string

	// Rate limit in bytes per second or IO operations per second.
	rate?: int | string
})

// Block IO weight for a specific device.
#blkio_weight: close({
	// Path to the device (e.g., '/dev/sda').
	path?: string

	// Relative weight for the device, between 10 and 1000.
	weight?: int | string
})

// Command to run in the container, which can be specified as a
// string (shell form) or array (exec form).
#command: matchN(1, [null, string, [...string]])

// Config configuration for the Compose application.
#Config: close({
	// Custom name for this config.
	name?: string

	// Inline content of the config.
	content?: string

	// Name of an environment variable from which to get the config
	// value.
	environment?: string

	// Path to a file containing the config value.
	file?: string

	// Specifies that this config already exists and was created
	// outside of Compose.
	external?: bool | string | {
		// Specifies the name of the external config. Deprecated: use the
		// 'name' property instead.
		name?: string @deprecated()
		...
	}

	// Add metadata to the config using labels.
	labels?: #list_or_dict

	// Driver to use for templating the config's value.
	template_driver?: string

	{[=~"^x-" & !~"^(name|content|environment|file|external|labels|template_driver)$"]: _}
})

// Deployment configuration for the service.
#deployment: null | close({
	// Deployment mode for the service: 'replicated' (default) or
	// 'global'.
	mode?: string

	// Endpoint mode for the service: 'vip' (default) or 'dnsrr'.
	endpoint_mode?: string

	// Number of replicas of the service container to run.
	replicas?: int | string

	// Labels to apply to the service.
	labels?: #list_or_dict

	// Configuration for rolling back a service update.
	rollback_config?: close({
		// The number of containers to rollback at a time. If set to 0,
		// all containers rollback simultaneously.
		parallelism?: int | string

		// The time to wait between each container group's rollback (e.g.,
		// '1s', '1m30s').
		delay?: string

		// Action to take if a rollback fails: 'continue', 'pause'.
		failure_action?: string

		// Duration to monitor each task for failures after it is created
		// (e.g., '1s', '1m30s').
		monitor?: string

		// Failure rate to tolerate during a rollback.
		max_failure_ratio?: number | string

		// Order of operations during rollbacks: 'stop-first' (default) or
		// 'start-first'.
		order?: "start-first" | "stop-first"

		{[=~"^x-" & !~"^(parallelism|delay|failure_action|monitor|max_failure_ratio|order)$"]: _}
	})

	// Configuration for updating a service.
	update_config?: close({
		// The number of containers to update at a time.
		parallelism?: int | string

		// The time to wait between updating a group of containers (e.g.,
		// '1s', '1m30s').
		delay?: string

		// Action to take if an update fails: 'continue', 'pause',
		// 'rollback'.
		failure_action?: string

		// Duration to monitor each updated task for failures after it is
		// created (e.g., '1s', '1m30s').
		monitor?: string

		// Failure rate to tolerate during an update (0 to 1).
		max_failure_ratio?: number | string

		// Order of operations during updates: 'stop-first' (default) or
		// 'start-first'.
		order?: "start-first" | "stop-first"

		{[=~"^x-" & !~"^(parallelism|delay|failure_action|monitor|max_failure_ratio|order)$"]: _}
	})

	// Resource constraints and reservations for the service.
	resources?: close({
		// Resource limits for the service containers.
		limits?: close({
			// Limit for how much of the available CPU resources, as number of
			// cores, a container can use.
			cpus?: number | string

			// Limit on the amount of memory a container can allocate (e.g.,
			// '1g', '1024m').
			memory?: string

			// Maximum number of PIDs available to the container.
			pids?: int | string

			{[=~"^x-" & !~"^(cpus|memory|pids)$"]: _}
		})

		// Resource reservations for the service containers.
		reservations?: close({
			// Reservation for how much of the available CPU resources, as
			// number of cores, a container can use.
			cpus?: number | string

			// Reservation on the amount of memory a container can allocate
			// (e.g., '1g', '1024m').
			memory?: string

			// User-defined resources to reserve.
			generic_resources?: #generic_resources

			// Device reservations for the container.
			devices?: #devices

			{[=~"^x-" & !~"^(cpus|memory|generic_resources|devices)$"]: _}
		})

		{[=~"^x-" & !~"^(limits|reservations)$"]: _}
	})

	// Restart policy for the service containers.
	restart_policy?: close({
		// Condition for restarting the container: 'none', 'on-failure',
		// 'any'.
		condition?: string

		// Delay between restart attempts (e.g., '1s', '1m30s').
		delay?: string

		// Maximum number of restart attempts before giving up.
		max_attempts?: int | string

		// Time window used to evaluate the restart policy (e.g., '1s',
		// '1m30s').
		window?: string

		{[=~"^x-" & !~"^(condition|delay|max_attempts|window)$"]: _}
	})

	// Constraints and preferences for the platform to select a
	// physical node to run service containers
	placement?: close({
		// Placement constraints for the service (e.g.,
		// 'node.role==manager').
		constraints?: [...string]

		// Placement preferences for the service.
		preferences?: [...close({
			// Spread tasks evenly across values of the specified node label.
			spread?: string

			{[=~"^x-" & !~"^(spread)$"]: _}
		})]

		// Maximum number of replicas of the service.
		max_replicas_per_node?: int | string

		{[=~"^x-" & !~"^(constraints|preferences|max_replicas_per_node)$"]: _}
	})

	{[=~"^x-" & !~"^(mode|endpoint_mode|replicas|labels|rollback_config|update_config|resources|restart_policy|placement)$"]: _}
})

// Development configuration for the service, used for development
// workflows.
#development: null | close({
	// Configure watch mode for the service, which monitors file
	// changes and performs actions in response.
	watch?: [...close({
		// Patterns to exclude from watching.
		ignore?: #string_or_list

		// Patterns to include in watching.
		include?: #string_or_list

		// Path to watch for changes.
		path!: string

		// Action to take when a change is detected: rebuild the
		// container, sync files, restart the container, sync and
		// restart, or sync and execute a command.
		action!: "rebuild" | "sync" | "restart" | "sync+restart" | "sync+exec"

		// Target path in the container for sync operations.
		target?: string

		// Command to execute when a change is detected and action is
		// sync+exec.
		exec?: #service_hook

		{[=~"^x-" & !~"^(ignore|include|path|action|target|exec)$"]: _}
	})]

	{[=~"^x-" & !~"^(watch)$"]: _}
})

// Device reservations for containers, allowing services to access
// specific hardware devices.
#devices: [...close({
	// List of capabilities the device needs to have (e.g., 'gpu',
	// 'compute', 'utility').
	capabilities!: #list_of_strings

	// Number of devices of this type to reserve.
	count?: int | string

	// List of specific device IDs to reserve.
	device_ids?: #list_of_strings

	// Device driver to use (e.g., 'nvidia').
	driver?: string

	// Driver-specific options for the device.
	options?: #list_or_dict

	{[=~"^x-" & !~"^(capabilities|count|device_ids|driver|options)$"]: _}
})]

#env_file: matchN(1, [string, [...matchN(1, [string, close({
	// Path to the environment file.
	path!: string

	// Format attribute lets you to use an alternative file formats
	// for env_file. When not set, env_file is parsed according to
	// Compose rules.
	format?: string

	// Whether the file is required. If true and the file doesn't
	// exist, an error will be raised.
	required?: bool | string
})])]])

// Additional hostnames to be defined in the container's
// /etc/hosts file.
#extra_hosts: matchN(1, [close({
	{[=~".+"]: matchN(1, [string, [...string]])}
}), list.UniqueItems() & [...string]])

// User-defined resources for services, allowing services to
// reserve specialized hardware resources.
#generic_resources: [...close({
	// Specification for discrete (countable) resources.
	discrete_resource_spec?: close({
		// Type of resource (e.g., 'GPU', 'FPGA', 'SSD').
		kind?: string

		// Number of resources of this kind to reserve.
		value?: number | string

		{[=~"^x-" & !~"^(kind|value)$"]: _}
	})

	{[=~"^x-" & !~"^(discrete_resource_spec)$"]: _}
})]

#gpus: matchN(1, ["all", [...{
	// List of capabilities the GPU needs to have (e.g., 'compute',
	// 'utility').
	capabilities?: #list_of_strings

	// Number of GPUs to use.
	count?: int | string

	// List of specific GPU device IDs to use.
	device_ids?: #list_of_strings

	// GPU driver to use (e.g., 'nvidia').
	driver?: string

	// Driver-specific options for the GPU.
	options?: #list_or_dict
	...
}]])

// Configuration options to determine whether the container is
// healthy.
#healthcheck: close({
	// Disable any container-specified healthcheck. Set to true to
	// disable.
	disable?: bool | string

	// Time between running the check (e.g., '1s', '1m30s'). Default:
	// 30s.
	interval?: string

	// Number of consecutive failures needed to consider the container
	// as unhealthy. Default: 3.
	retries?: number | string

	// The test to perform to check container health. Can be a string
	// or a list. The first item is either NONE, CMD, or CMD-SHELL.
	// If it's CMD, the rest of the command is exec'd. If it's
	// CMD-SHELL, the rest is run in the shell.
	test?: matchN(1, [string, [...string]])

	// Maximum time to allow one check to run (e.g., '1s', '1m30s').
	// Default: 30s.
	timeout?: string

	// Start period for the container to initialize before starting
	// health-retries countdown (e.g., '1s', '1m30s'). Default: 0s.
	start_period?: string

	// Time between running the check during the start period (e.g.,
	// '1s', '1m30s'). Default: interval value.
	start_interval?: string

	{[=~"^x-" & !~"^(disable|interval|retries|test|timeout|start_period|start_interval)$"]: _}
})

// Compose application or sub-projects to be included.
#Include: matchN(1, [string, close({
	// Path to the Compose application or sub-project files to
	// include.
	path?: #string_or_list

	// Path to the environment files to use to define default values
	// when interpolating variables in the Compose files being
	// parsed.
	env_file?: #string_or_list

	// Path to resolve relative paths set in the Compose file
	project_directory?: string
})])

#label_file: matchN(1, [string, [...string]])

// A list of unique string values.
#list_of_strings: list.UniqueItems() & [...string]

// Either a dictionary mapping keys to values, or a list of
// strings.
#list_or_dict: matchN(1, [close({
	{[=~".+"]: null | bool | number | string}
}), list.UniqueItems() & [...string]])
// #list_or_dict: [string]: string | int | bool

// Network configuration for the Compose application.
#Network: null | close({
	// Custom name for this network.
	name?: string

	// Specify which driver should be used for this network. Default
	// is 'bridge'.
	driver?: string

	// Specify driver-specific options defined as key/value pairs.
	driver_opts?: {
		{[=~"^.+$"]: number | string}
		...
	}

	// Custom IP Address Management configuration for this network.
	ipam?: close({
		// Custom IPAM driver, instead of the default.
		driver?: string

		// List of IPAM configuration blocks.
		config?: [...close({
			// Subnet in CIDR format that represents a network segment.
			subnet?: string

			// Range of IPs from which to allocate container IPs.
			ip_range?: string

			// IPv4 or IPv6 gateway for the subnet.
			gateway?: string

			// Auxiliary IPv4 or IPv6 addresses used by Network driver.
			aux_addresses?: close({
				{[=~"^.+$"]: string}
			})

			{[=~"^x-" & !~"^(subnet|ip_range|gateway|aux_addresses)$"]: _}
		})]

		// Driver-specific options for the IPAM driver.
		options?: close({
			{[=~"^.+$"]: string}
		})

		{[=~"^x-" & !~"^(driver|config|options)$"]: _}
	})

	// Specifies that this network already exists and was created
	// outside of Compose.
	external?: bool | string | close({
		// Specifies the name of the external network. Deprecated: use the
		// 'name' property instead.
		name?: string @deprecated()

		{[=~"^x-" & !~"^(name)$"]: _}
	})

	// Create an externally isolated network.
	internal?: bool | string

	// Enable IPv4 networking.
	enable_ipv4?: bool | string

	// Enable IPv6 networking.
	enable_ipv6?: bool | string

	// If true, standalone containers can attach to this network.
	attachable?: bool | string

	// Add metadata to the network using labels.
	labels?: #list_or_dict

	{[=~"^x-" & !~"^(name|driver|driver_opts|ipam|external|internal|enable_ipv4|enable_ipv6|attachable|labels)$"]: _}
})

// Secret configuration for the Compose application.
#Secret: close({
	// Custom name for this secret.
	name?: string

	// Name of an environment variable from which to get the secret
	// value.
	environment?: string

	// Path to a file containing the secret value.
	file?: string

	// Specifies that this secret already exists and was created
	// outside of Compose.
	external?: bool | string | {
		// Specifies the name of the external secret.
		name?: string
		...
	}

	// Add metadata to the secret using labels.
	labels?: #list_or_dict

	// Specify which secret driver should be used for this secret.
	driver?: string

	// Specify driver-specific options.
	driver_opts?: {
		{[=~"^.+$"]: number | string}
		...
	}

	// Driver to use for templating the secret's value.
	template_driver?: string

	{[=~"^x-" & !~"^(name|environment|file|external|labels|driver|driver_opts|template_driver)$"]: _}
})

// Configuration for a service.
#Service: close({
	develop?:     #development
	deploy?:      #deployment
	annotations?: #list_or_dict
	attach?:      bool | string

	// Configuration options for building the service's image.
	build?: matchN(1, [string, close({
		// Path to the build context. Can be a relative path or a URL.
		context?: string

		// Name of the Dockerfile to use for building the image.
		dockerfile?: string

		// Inline Dockerfile content to use instead of a Dockerfile from
		// the build context.
		dockerfile_inline?: string

		// List of extra privileged entitlements to grant to the build
		// process.
		entitlements?: [...string]

		// Build-time variables, specified as a map or a list of KEY=VAL
		// pairs.
		args?: #list_or_dict

		// SSH agent socket or keys to expose to the build. Format is
		// either a string or a list of
		// 'default|<id>[=<socket>|<key>[,<key>]]'.
		ssh?: #list_or_dict

		// Labels to apply to the built image.
		labels?: #list_or_dict

		// List of sources the image builder should use for cache
		// resolution
		cache_from?: [...string]

		// Cache destinations for the build cache.
		cache_to?: [...string]

		// Do not use cache when building the image.
		no_cache?: bool | string

		// Additional build contexts to use, specified as a map of name to
		// context path or URL.
		additional_contexts?: #list_or_dict

		// Network mode to use for the build. Options include 'default',
		// 'none', 'host', or a network name.
		network?: string

		// Always attempt to pull a newer version of the image.
		pull?: bool | string

		// Build stage to target in a multi-stage Dockerfile.
		target?: string

		// Size of /dev/shm for the build container. A string value can
		// use suffix like '2g' for 2 gigabytes.
		shm_size?: int | string

		// Add hostname mappings for the build container.
		extra_hosts?: #extra_hosts

		// Container isolation technology to use for the build process.
		isolation?: string

		// Give extended privileges to the build container.
		privileged?: bool | string

		// Secrets to expose to the build. These are accessible at
		// build-time.
		secrets?: #service_config_or_secret

		// Additional tags to apply to the built image.
		tags?: [...string]

		// Override the default ulimits for the build container.
		ulimits?: #ulimits

		// Platforms to build for, e.g., 'linux/amd64', 'linux/arm64', or
		// 'windows/amd64'.
		platforms?: [...string]

		{[=~"^x-" & !~"^(context|dockerfile|dockerfile_inline|entitlements|args|ssh|labels|cache_from|cache_to|no_cache|additional_contexts|network|pull|target|shm_size|extra_hosts|isolation|privileged|secrets|tags|ulimits|platforms)$"]: _}
	})])

	// Block IO configuration for the service.
	blkio_config?: close({
		// Limit read rate (bytes per second) from a device.
		device_read_bps?: [...#blkio_limit]

		// Limit read rate (IO per second) from a device.
		device_read_iops?: [...#blkio_limit]

		// Limit write rate (bytes per second) to a device.
		device_write_bps?: [...#blkio_limit]

		// Limit write rate (IO per second) to a device.
		device_write_iops?: [...#blkio_limit]

		// Block IO weight (relative weight) for the service, between 10
		// and 1000.
		weight?: int | string

		// Block IO weight (relative weight) for specific devices.
		weight_device?: [...#blkio_weight]
	})

	// Add Linux capabilities. For example, 'CAP_SYS_ADMIN',
	// 'SYS_ADMIN', or 'NET_ADMIN'.
	cap_add?: list.UniqueItems() & [...string]

	// Drop Linux capabilities. For example, 'CAP_SYS_ADMIN',
	// 'SYS_ADMIN', or 'NET_ADMIN'.
	cap_drop?: list.UniqueItems() & [...string]

	// Specify the cgroup namespace to join. Use 'host' to use the
	// host's cgroup namespace, or 'private' to use a private cgroup
	// namespace.
	cgroup?: "host" | "private"

	// Specify an optional parent cgroup for the container.
	cgroup_parent?: string

	// Override the default command declared by the container image,
	// for example 'CMD' in Dockerfile.
	command?: #command

	// Grant access to Configs on a per-service basis.
	configs?: #service_config_or_secret

	// Specify a custom container name, rather than a generated
	// default name.
	container_name?: string

	// Number of usable CPUs.
	cpu_count?: matchN(1, [string, int & >=0])

	// Percentage of CPU resources to use.
	cpu_percent?: matchN(1, [string, int & >=0 & <=100])

	// CPU shares (relative weight) for the container.
	cpu_shares?: number | string

	// Limit the CPU CFS (Completely Fair Scheduler) quota.
	cpu_quota?: number | string

	// Limit the CPU CFS (Completely Fair Scheduler) period.
	cpu_period?: number | string

	// Limit the CPU real-time period in microseconds or a duration.
	cpu_rt_period?: number | string

	// Limit the CPU real-time runtime in microseconds or a duration.
	cpu_rt_runtime?: number | string

	// Number of CPUs to use. A floating-point value is supported to
	// request partial CPUs.
	cpus?: number | string

	// CPUs in which to allow execution (0-3, 0,1).
	cpuset?: string

	// Configure the credential spec for managed service account.
	credential_spec?: close({
		// The name of the credential spec Config to use.
		config?: string

		// Path to a credential spec file.
		file?: string

		// Path to a credential spec in the Windows registry.
		registry?: string

		{[=~"^x-" & !~"^(config|file|registry)$"]: _}
	})

	// Express dependency between services. Service dependencies cause
	// services to be started in dependency order. The dependent
	// service will wait for the dependency to be ready before
	// starting.
	depends_on?: matchN(1, [#list_of_strings, close({
		{[=~"^[a-zA-Z0-9._-]+$"]: close({
			// Whether to restart dependent services when this service is
			// restarted.
			restart?: bool | string

			// Whether the dependency is required for the dependent service to
			// start.
			required?: bool

			// Condition to wait for. 'service_started' waits until the
			// service has started, 'service_healthy' waits until the service
			// is healthy (as defined by its healthcheck),
			// 'service_completed_successfully' waits until the service has
			// completed successfully.
			condition!: "service_started" | "service_healthy" | "service_completed_successfully"

			{[=~"^x-" & !~"^(restart|required|condition)$"]: _}
		})
		}
	})])

	// Add rules to the cgroup allowed devices list.
	device_cgroup_rules?: #list_of_strings

	// List of device mappings for the container.
	devices?: [...matchN(1, [string, close({
		// Path on the host to the device.
		source!: string

		// Path in the container where the device will be mapped.
		target?: string

		// Cgroup permissions for the device (rwm).
		permissions?: string

		{[=~"^x-" & !~"^(source|target|permissions)$"]: _}
	})])]

	// Custom DNS servers to set for the service container.
	dns?: #string_or_list

	// Custom DNS options to be passed to the container's DNS
	// resolver.
	dns_opt?: list.UniqueItems() & [...string]

	// Custom DNS search domains to set on the service container.
	dns_search?: #string_or_list

	// Custom domain name to use for the service container.
	domainname?: string

	// Override the default entrypoint declared by the container
	// image, for example 'ENTRYPOINT' in Dockerfile.
	entrypoint?: #command

	// Add environment variables from a file or multiple files. Can be
	// a single file path or a list of file paths.
	env_file?: #env_file

	// Add metadata to containers using files containing Docker
	// labels.
	label_file?: #label_file

	// Add environment variables. You can use either an array or a
	// list of KEY=VAL pairs.
	environment?: #list_or_dict

	// Expose ports without publishing them to the host machine -
	// they'll only be accessible to linked services.
	expose?: list.UniqueItems() & [...number | string]

	// Extend another service, in the current file or another file.
	extends?: matchN(1, [string, close({
		// The name of the service to extend.
		service!: string

		// The file path where the service to extend is defined.
		file?: string
	})])

	// Specify a service which will not be manage by Compose directly,
	// and delegate its management to an external provider.
	provider?: close({
		// External component used by Compose to manage setup and teardown
		// lifecycle of the service.
		type?: string

		// Provider-specific options.
		options?: {
			{[=~"^.+$"]: null | number | string}
			...
		}

		{[=~"^x-" & !~"^(type|options)$"]: _}
	})

	// Link to services started outside this Compose application.
	// Specify services as <service_name>:<alias>.
	external_links?: list.UniqueItems() & [...string]

	// Add hostname mappings to the container network interface
	// configuration.
	extra_hosts?: #extra_hosts

	// Define GPU devices to use. Can be set to 'all' to use all GPUs,
	// or a list of specific GPU devices.
	gpus?: #gpus

	// Add additional groups which user inside the container should be
	// member of.
	group_add?: list.UniqueItems() & [...number | string]

	// Configure a health check for the container to monitor its
	// health status.
	healthcheck?: #healthcheck

	// Define a custom hostname for the service container.
	hostname?: string

	// Specify the image to start the container from. Can be a
	// repository/tag, a digest, or a local image ID.
	image?: string

	// Run as an init process inside the container that forwards
	// signals and reaps processes.
	init?: bool | string

	// IPC sharing mode for the service container. Use 'host' to share
	// the host's IPC namespace, 'service:[service_name]' to share
	// with another service, or 'shareable' to allow other services
	// to share this service's IPC namespace.
	ipc?: string

	// Container isolation technology to use. Supported values are
	// platform-specific.
	isolation?: string

	// Add metadata to containers using Docker labels. You can use
	// either an array or a list.
	labels?: #list_or_dict

	// Link to containers in another service. Either specify both the
	// service name and a link alias (SERVICE:ALIAS), or just the
	// service name.
	links?: list.UniqueItems() & [...string]

	// Logging configuration for the service.
	logging?: close({
		// Logging driver to use, such as 'json-file', 'syslog',
		// 'journald', etc.
		driver?: string

		// Options for the logging driver.
		options?: {
			{[=~"^.+$"]: null | number | string}
			...
		}

		{[=~"^x-" & !~"^(driver|options)$"]: _}
	})

	// Container MAC address to set.
	mac_address?: string

	// Memory limit for the container. A string value can use suffix
	// like '2g' for 2 gigabytes.
	mem_limit?: number | string

	// Memory reservation for the container.
	mem_reservation?: int | string

	// Container memory swappiness as percentage (0 to 100).
	mem_swappiness?: int | string

	// Amount of memory the container is allowed to swap to disk. Set
	// to -1 to enable unlimited swap.
	memswap_limit?: number | string

	// Network mode. Values can be 'bridge', 'host', 'none',
	// 'service:[service name]', or 'container:[container name]'.
	network_mode?: string

	// Networks to join, referencing entries under the top-level
	// networks key. Can be a list of network names or a mapping of
	// network name to network configuration.
	networks?: matchN(1, [#list_of_strings, close({
		{[=~"^[a-zA-Z0-9._-]+$"]: matchN(1, [close({
			// Alternative hostnames for this service on the network.
			aliases?: #list_of_strings

			// Interface network name used to connect to network
			interface_name?: string

			// Specify a static IPv4 address for this service on this network.
			ipv4_address?: string

			// Specify a static IPv6 address for this service on this network.
			ipv6_address?: string

			// List of link-local IPs.
			link_local_ips?: #list_of_strings

			// Specify a MAC address for this service on this network.
			mac_address?: string

			// Driver options for this network.
			driver_opts?: {
				{[=~"^.+$"]: number | string}
				...
			}

			// Specify the priority for the network connection.
			priority?: number

			// Specify the gateway priority for the network connection.
			gw_priority?: number

			{[=~"^x-" & !~"^(aliases|interface_name|ipv4_address|ipv6_address|link_local_ips|mac_address|driver_opts|priority|gw_priority)$"]: _}
		}), null])
		}
	})])

	// Disable OOM Killer for the container.
	oom_kill_disable?: bool | string

	// Tune host's OOM preferences for the container (accepts -1000 to
	// 1000).
	oom_score_adj?: matchN(1, [string, int & >=-1000 & <=1000])

	// PID mode for container.
	pid?: null | string

	// Tune a container's PIDs limit. Set to -1 for unlimited PIDs.
	pids_limit?: number | string

	// Target platform to run on, e.g., 'linux/amd64', 'linux/arm64',
	// or 'windows/amd64'.
	platform?: string

	// Expose container ports. Short format
	// ([HOST:]CONTAINER[/PROTOCOL]).
	ports?: list.UniqueItems() & [...matchN(1, [number, string, close({
		// A human-readable name for this port mapping.
		name?: string

		// The port binding mode, either 'host' for publishing a host port
		// or 'ingress' for load balancing.
		mode?: string

		// The host IP to bind to.
		host_ip?: string

		// The port inside the container.
		target?: int | string

		// The publicly exposed port.
		published?: int | string

		// The port protocol (tcp or udp).
		protocol?: string

		// Application protocol to use with the port (e.g., http, https,
		// mysql).
		app_protocol?: string

		{[=~"^x-" & !~"^(name|mode|host_ip|target|published|protocol|app_protocol)$"]: _}
	})])]

	// Commands to run after the container starts. If any command
	// fails, the container stops.
	post_start?: [...#service_hook]

	// Commands to run before the container stops. If any command
	// fails, the container stop is aborted.
	pre_stop?: [...#service_hook]

	// Give extended privileges to the service container.
	privileged?: bool | string

	// List of profiles for this service. When profiles are specified,
	// services are only started when the profile is activated.
	profiles?: #list_of_strings

	// Policy for pulling images. Options include: 'always', 'never',
	// 'if_not_present', 'missing', 'build', or time-based refresh
	// policies.
	pull_policy?: #PullPolicy

	// Time after which to refresh the image. Used with
	// pull_policy=refresh.
	pull_refresh_after?: string

	// Mount the container's filesystem as read only.
	read_only?: bool | string

	// Restart policy for the service container. Options include:
	// 'no', 'always', 'on-failure', and 'unless-stopped'.
	restart?: #RestartPolicy

	// Runtime to use for this container, e.g., 'runc'.
	runtime?: string

	// Number of containers to deploy for this service.
	scale?: int | string

	// Override the default labeling scheme for each container.
	security_opt?: list.UniqueItems() & [...string]

	// Size of /dev/shm. A string value can use suffix like '2g' for 2
	// gigabytes.
	shm_size?: number | string

	// Grant access to Secrets on a per-service basis.
	secrets?: #service_config_or_secret

	// Kernel parameters to set in the container. You can use either
	// an array or a list.
	sysctls?: #list_or_dict

	// Keep STDIN open even if not attached.
	stdin_open?: bool | string

	// Time to wait for the container to stop gracefully before
	// sending SIGKILL (e.g., '1s', '1m30s').
	stop_grace_period?: string

	// Signal to stop the container (e.g., 'SIGTERM', 'SIGINT').
	stop_signal?: string

	// Storage driver options for the container.
	storage_opt?: {
		...
	}

	// Mount a temporary filesystem (tmpfs) into the container. Can be
	// a single value or a list.
	tmpfs?: #string_or_list

	// Allocate a pseudo-TTY to service container.
	tty?: bool | string

	// Override the default ulimits for a container.
	ulimits?: #ulimits

	// Username or UID to run the container process as.
	user?: string

	// UTS namespace to use. 'host' shares the host's UTS namespace.
	uts?: string

	// User namespace to use. 'host' shares the host's user namespace.
	userns_mode?: string

	// Mount host paths or named volumes accessible to the container.
	// Short syntax (VOLUME:CONTAINER_PATH[:MODE])
	volumes?: list.UniqueItems() & [...matchN(1, [string, close({
		// The mount type: bind for mounting host directories, volume for
		// named volumes, tmpfs for temporary filesystems, cluster for
		// cluster volumes, npipe for named pipes, or image for mounting
		// from an image.
		type!: "bind" | "volume" | "tmpfs" | "cluster" | "npipe" | "image"

		// The source of the mount, a path on the host for a bind mount, a
		// docker image reference for an image mount, or the name of a
		// volume defined in the top-level volumes key. Not applicable
		// for a tmpfs mount.
		source?: string

		// The path in the container where the volume is mounted.
		target?: string

		// Flag to set the volume as read-only.
		read_only?: bool | string

		// The consistency requirements for the mount. Available values
		// are platform specific.
		consistency?: string

		// Configuration specific to bind mounts.
		bind?: close({
			// The propagation mode for the bind mount: 'shared', 'slave',
			// 'private', 'rshared', 'rslave', or 'rprivate'.
			propagation?: string

			// Create the host path if it doesn't exist.
			create_host_path?: bool | string

			// Recursively mount the source directory.
			recursive?: "enabled" | "disabled" | "writable" | "readonly"

			// SELinux relabeling options: 'z' for shared content, 'Z' for
			// private unshared content.
			selinux?: "z" | "Z"

			{[=~"^x-" & !~"^(propagation|create_host_path|recursive|selinux)$"]: _}
		})

		// Configuration specific to volume mounts.
		volume?: close({
			// Labels to apply to the volume.
			labels?: #list_or_dict

			// Flag to disable copying of data from a container when a volume
			// is created.
			nocopy?: bool | string

			// Path within the volume to mount instead of the volume root.
			subpath?: string

			{[=~"^x-" & !~"^(labels|nocopy|subpath)$"]: _}
		})

		// Configuration specific to tmpfs mounts.
		tmpfs?: close({
			// Size of the tmpfs mount in bytes.
			size?: matchN(1, [int & >=0, string])

			// File mode of the tmpfs in octal.
			mode?: number | string

			{[=~"^x-" & !~"^(size|mode)$"]: _}
		})

		// Configuration specific to image mounts.
		image?: close({
			// Path within the image to mount instead of the image root.
			subpath?: string

			{[=~"^x-" & !~"^(subpath)$"]: _}
		})

		{[=~"^x-" & !~"^(type|source|target|read_only|consistency|bind|volume|tmpfs|image)$"]: _}
	})])]

	// Mount volumes from another service or container. Optionally
	// specify read-only access (ro) or read-write (rw).
	volumes_from?: list.UniqueItems() & [...string]

	// The working directory in which the entrypoint or command will
	// be run
	working_dir?: string

	{[=~"^x-" & !~"^(develop|deploy|annotations|attach|build|blkio_config|cap_add|cap_drop|cgroup|cgroup_parent|command|configs|container_name|cpu_count|cpu_percent|cpu_shares|cpu_quota|cpu_period|cpu_rt_period|cpu_rt_runtime|cpus|cpuset|credential_spec|depends_on|device_cgroup_rules|devices|dns|dns_opt|dns_search|domainname|entrypoint|env_file|label_file|environment|expose|extends|provider|external_links|extra_hosts|gpus|group_add|healthcheck|hostname|image|init|ipc|isolation|labels|links|logging|mac_address|mem_limit|mem_reservation|mem_swappiness|memswap_limit|network_mode|networks|oom_kill_disable|oom_score_adj|pid|pids_limit|platform|ports|post_start|pre_stop|privileged|profiles|pull_policy|pull_refresh_after|read_only|restart|runtime|scale|security_opt|shm_size|secrets|sysctls|stdin_open|stop_grace_period|stop_signal|storage_opt|tmpfs|tty|ulimits|user|uts|userns_mode|volumes|volumes_from|working_dir)$"]: _}
})

// Configuration for service configs or secrets, defining how they
// are mounted in the container.
#service_config_or_secret: [...matchN(1, [string, close({
	// Name of the config or secret as defined in the top-level
	// configs or secrets section.
	source?: string

	// Path in the container where the config or secret will be
	// mounted. Defaults to /<source> for configs and
	// /run/secrets/<source> for secrets.
	target?: string

	// UID of the file in the container. Default is 0 (root).
	uid?: string

	// GID of the file in the container. Default is 0 (root).
	gid?: string

	// File permission mode inside the container, in octal. Default is
	// 0444 for configs and 0400 for secrets.
	mode?: number | string

	{[=~"^x-" & !~"^(source|target|uid|gid|mode)$"]: _}
})])]

// Configuration for service lifecycle hooks, which are commands
// executed at specific points in a container's lifecycle.
#service_hook: close({
	// Command to execute as part of the hook.
	command!: #command

	// User to run the command as.
	user?: string

	// Whether to run the command with extended privileges.
	privileged?: bool | string

	// Working directory for the command.
	working_dir?: string

	// Environment variables for the command.
	environment?: #list_or_dict

	{[=~"^x-" & !~"^(command|user|privileged|working_dir|environment)$"]: _}
})

// Either a single string or a list of strings.
#string_or_list: matchN(1, [string, #list_of_strings])

// Container ulimit options, controlling resource limits for
// processes inside the container.
#ulimits: {
	{[=~"^[a-z]+$"]: matchN(1, [int | string, close({
		// Hard limit for the ulimit type. This is the maximum allowed
		// value.
		hard!: int | string

		// Soft limit for the ulimit type. This is the value that's
		// actually enforced.
		soft!: int | string

		{[=~"^x-" & !~"^(hard|soft)$"]: _}
	})])
	}
	...
}

// Volume configuration for the Compose application.
#Volume: null | close({
	// Custom name for this volume.
	name?: string

	// Specify which volume driver should be used for this volume.
	driver?: string

	// Specify driver-specific options.
	driver_opts?: {
		{[=~"^.+$"]: number | string}
		...
	}

	// Specifies that this volume already exists and was created
	// outside of Compose.
	external?: bool | string | close({
		// Specifies the name of the external volume. Deprecated: use the
		// 'name' property instead.
		name?: string @deprecated()

		{[=~"^x-" & !~"^(name)$"]: _}
	})

	// Add metadata to the volume using labels.
	labels?: #list_or_dict

	{[=~"^x-" & !~"^(name|driver|driver_opts|external|labels)$"]: _}
})

#RestartPolicy: string & "no" | "always" | "on-failure" | "unless-stopped"

#PullPolicy: string & =~"always|never|build|if_not_present|missing|refresh|daily|weekly|every_([0-9]+[wdhms])+"