# cue-oam

Project to experiment with Open Application Model and a docker compose implementation using pure CUE transformers.

## Why?

I wanted to find out if it is possible to utilize CUE fully to define, compose and transform configuration into any platform (e.g Docker Compose or Kubernetes).

## Key features

- Using pure CUE for everything
  - Scripting, data and validation
- Transforms from a common schema to either Kubernetes manifests or raw Docker Compose

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
