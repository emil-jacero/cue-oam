package generic

#TaskContainerSpec: {
	// The container image to use.
	image!: #Image

	// Secrets to use when pulling the container image.
	imagePullSecrets?: [...#Secret]

	// Command to run in the container.
	command?: [...string]

	// Arguments to pass to the command.
	args?: [...string]

	// List of environment variables to set in the container.
	env?: [...#EnvVar]

	// Resources required by the container.
	// Requests describes the minimum amount of compute resources required.
	// If Requests is omitted for a container, it defaults to an implementation-defined value.
	// Limits describes the maximum amount of compute resources allowed.
	// If Limits is omitted for a container, it defaults to an implementation-defined value.
	// Requests cannot exceed Limits.
	resources?: #ResourceRequirements

	// Volumes that can be mounted into the container.
	// The volume can be defined here or passed in here from another definition inheriting from #Volume.
	volumeMounts?: [...#Volume]

	restartPolicy?: #RestartPolicy

	// Instructions for assessing whether the container is alive.
	livenessProbe?: #HealthProbe

	// Instructions for assessing whether the container is in a
	// suitable state to serve traffic.
	readinessProbe?: #HealthProbe

	labels?: [string]:      string
	annotations?: [string]: string
}
