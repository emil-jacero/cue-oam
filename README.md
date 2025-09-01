# cue-oam

A pure [CUE](https://cuelang.org) implementation of the [Open Application Model](https://oam.dev) (OAM) specification with transformers for Docker Compose and Kubernetes.

This project demonstrates how to use CUE's powerful type system and transformations to implement OAM abstractions that can target multiple deployment platforms without external tooling.

> [!NOTE]
> The API and schema is under heavy development and could therefore have a lot of breaking changes!

## Why?

I wanted to find out if it is possible to utilize CUE fully to define, compose and transform configuration into any platform (e.g Docker Compose or Kubernetes).

## Key Features

- **Pure CUE Implementation** - No external tools or scripts required
- **OAM Compliant** - Follows Open Application Model v2alpha1 specification
- **Multi-Platform Output** - Transform to Docker Compose or Kubernetes from the same definitions
- **Type Safety** - Leverage CUE's type system for validation and constraints
- **Composable Components** - Build complex applications from reusable parts

## Terms and Definitions

### Platform Operator

The platform engineers initialize the deployment environments, provide stable infrastructure capabilities (e.g. mysql-operator) and register them as reusable templates using Workload and Components into the control plane.

### End User

The person consuming Applications. The end users are usually app developers. They choose target environment, and choose capability templates, fill in values and finally assemble them as an Application. They don't need to understand the infrastructure details, because they rely on the included Components and Traits.

### Component

Components are modular building blocks of a system, similar to lego pieces. Each has a distinct purpose but can be combined seamlessly with others to form larger applications.
A component must inherit a schema (described above). This could either be a complex schema, that describes multiple containers and their resources, or it could be a simple schema, like a ContainerSpec.
In practice, a simple containerized workload, a Helm chart, or a cloud database (DaaS) may all be modeled as a component.

For example, a simple web service component may define a single container with ports and volumes. By default, when ports are exposed, it automatically generates a Kubernetes Service and exposes the ports for Docker Compose.

Components also carry a set of well-known attributes, that inform traits, scopes and policies on how to act on the component.

```cue
// Whether the component supports replication and scaling.
replicable?: bool

// Whether the workload must run continuously. 
// Daemonized workloads treat exit as a fault; non-daemonized workloads 
// treat exit as success if no error is reported.
daemonized?: bool

// Whether the component exposes a stable service endpoint.
// Exposed workloads require a VIP and DNS name within their network scope.
exposed?: bool

// Whether the workload can be represented as a Kubernetes PodSpec.
// If true, implementations may manipulate the workload via PodSpec structures.
podspecable?: bool
```

### ComponentType

A component-type is a reusable set of CUE definitions that ensures components, traits, and scopes share the same upstream standards.
A set of global schemas are part of the model specification, but other schemas may be created and maintained by a platform. They serve the same purpose, and should be well-known to the users of that platform.

### Trait

Traits extend or modify components by adjusting their runtime behavior (e.g., autoscaling, ingress) or by modifying / attaching new resources.

### Scopes

Scopes define logical or operational boundaries that apply to multiple components, such as a network, region, or tenant. Scopes can be used to group components together.

Example: A common network scope, that allows multiple components to share a network, or by configuring a proxy (e.g. Traefik or Envoy) to automatically expose the correct ports and/or domain and path.

## Prerequisites

- [CUE](https://cuelang.org/docs/install/) v0.14.0 or higher

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/emil-jacero/cue-oam.git
   cd cue-oam
   ```

2. **Evaluate an application definition**

   ```bash
   cd examples/v2alpha2/application
   cue eval .
   ```

3. **Export to Docker Compose**

   ```bash
   cd examples/v2alpha2/application
   cue export -e "#Podinfo.kubernetes" --out yaml
   cue export -e "#Podinfo.compose" --out yaml > docker-compose.yml
   ```

4. **Run with Docker Compose**

   ```bash
   docker compose up -d
   ```

## Common Commands

- **Validate CUE syntax**: `cue vet <file.cue>`
- **Format CUE files**: `cue fmt <file.cue>`
- **Evaluate specific application**: `cue eval -e "#Podinfo"`
- **Export to Kubernetes**: `cue export -e "#Podinfo.kubernetes" --out yaml`

## Project Structure

```shell
cue-oam/
├── v2alpha2/
│   ├── core/               # Core OAM schemas (Application, Component, ComponentType, Trait, Scope)
│   ├── component_type/     # Reusable component type definitions
│   │   └── generic/        # Generic component types (webservice, worker, task)
│   ├── component/          # Component implementations
│   ├── platform/           # Platform transformers
│   │   └── compose/        # Docker Compose transformer
│   ├── schema/             # Schema definitions
│   ├── scope/              # Application scopes (WIP)
│   └── trait/              # Application traits (WIP)
├── examples/
│   ├── v2alpha1/           # v2alpha1 examples (legacy)
│   └── v2alpha2/
│       └── application/    # Example application definitions
├── oam-schema/             # OAM reference schemas
├── cue.mod/                # CUE module configuration
└── hack/                   # Testing utilities
```

## Contributing

This is an experimental project exploring OAM implementation in pure CUE. Contributions are welcome! Areas of focus:

- Completing the Kubernetes transformer
- Adding more workload types
- Creating Traits and Scopes
- Creating additional example applications

## License

[Add your license here]
