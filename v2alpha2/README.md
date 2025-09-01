# v2alpha2

## TODO

- [x] Base API and schema
- [ ] Dependency handling of components?
- [x] Test changing Workload to ComponentType or ComponentSchema

## Definitions

### ComponentSchema

A component-schema is a reusable set of CUE definitions that ensures components, traits, and scopes share the same upstream standards.
A set of global schemas are part of the model specification, but other schemas may be created and maintained by a platform. They serve the same purpose, and should be well-known to the users of that platform.

The platform directory is meant to contain transformation templates written in CUE, but they are similar to schemas. These templates accelerate development by mapping standard schemas into platform-specific outputs, such as Kubernetes manifests or Docker Compose files. By encapsulating common transformations, they reduce repetitive work and encourage reuse.

**Example:**

```cue
#ExampleFunc: {
    D=data!: #DataSpec
    result: #ResultSpec
    result: {
        // transformation logic, e.g.
        name: D.metadata.name
    }
}
```

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

### Application

An application is a higher-level package that groups components, traits, scopes, and policies. Applications are versioned, reusable, and can be shared across platforms.

### Trait

Traits extend or modify components by adjusting their runtime behavior (e.g., autoscaling, ingress) or by attaching new resources.”

### Scope

Scopes define logical or operational boundaries that apply to multiple components, such as a network, region, or tenant.

NOT YET IMPLEMENTED

### Policy

Policies enforce rules or constraints across components, traits, or scopes—for example, resource quotas, placement restrictions, or compliance requirements.

NOT YET IMPLEMENTED
