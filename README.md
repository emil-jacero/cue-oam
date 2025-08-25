# cue-oam

A pure [CUE](https://cuelang.org) implementation of the [Open Application Model](https://oam.dev) (OAM) specification with transformers for Docker Compose and Kubernetes.

This project demonstrates how to use CUE's powerful type system and transformations to implement OAM abstractions that can target multiple deployment platforms without external tooling.

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

A component is a deployable unit. It inherits a primary schema from a Workload but can be extended by Traits and Scopes when composed within an Application.

### Workload Type

A well known reusable schema, that makes it easier for component writers to implement providers for the output of the component.

### Trait

A _trait_ is a discretionary runtime overlay that augments a component workload instance with operational features. It represents an opportunity for those in the _application operator_ role to make specific decisions about the configuration of components, without having to involve the component provider or breaking the component encapsulation.

### Scopes

Application scopes are used to group components together into logical applications by providing different forms of application boundaries with common group behaviors.

Example: A common network scope, configuring a proxy (e.g. Traefik or Envoy) to automatically expose the correct ports and/or domain and path.

## Prerequisites

- [CUE](https://cuelang.org/docs/install/) v0.14.0 or higher

## Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/cue-oam.git
   cd cue-oam
   ```

2. **Evaluate an application definition**

   ```bash
   cd v2alpha1/application
   cue eval . --all
   ```

3. **Export to Docker Compose**

   ```bash
   cd v2alpha1/application
   cue export -e "#CodeServer.outputs.compose" --out yaml > docker-compose.yml
   ```

4. **Run with Docker Compose**

   ```bash
   docker compose up -d
   ```

## Common Commands

- **Validate CUE syntax**: `cue vet <file.cue>`
- **Format CUE files**: `cue fmt <file.cue>`
- **Evaluate specific application**: `cue eval -e "#CodeServer"`
- **Export to Kubernetes** (coming soon): `cue export -e "#CodeServer.outputs.kubernetes" --out yaml`

## Project Structure

```shell
cue-oam/
├── v2alpha1/
│   ├── core/           # Core OAM schemas
│   ├── workload/       # Workload type definitions
│   ├── component/      # Reusable components
│   ├── application/    # Application instances
│   ├── transformer/    # Platform transformers
│   └── scope/          # Application scopes (WIP)
├── cue.mod/           # CUE module configuration
└── hack/              # Testing utilities
```

## Contributing

This is an experimental project exploring OAM implementation in pure CUE. Contributions are welcome! Areas of focus:

- Completing the Kubernetes transformer
- Adding more workload types
- Creating Traits and Scopes
- Creating additional example applications

## License

[Add your license here]
