package compose

#Compose: {
	// define the Compose project name, until user defines one explicitly.
	name?: string

	// compose sub-projects to be included.
	include?: [...#include]

	// The services that will be used by your application.
	services?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #service}
	})

	// Networks that are shared among multiple services.
	networks?: {
		{[=~"^[a-zA-Z0-9._-]+$"]: #network}
		...
	}

	// Named volumes that are shared among multiple services.
	volumes?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #volume}
	})

	// Secrets that are shared among multiple services.
	secrets?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #secret}
	})

	// Configurations that are shared among multiple services.
	configs?: close({
		{[=~"^[a-zA-Z0-9._-]+$"]: #config}
	})
}
