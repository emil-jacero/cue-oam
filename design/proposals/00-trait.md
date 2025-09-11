# CUE-OAM Design Document: Unified Trait Architecture

2025-09-06

**Status:** Draft  
**Lifecycle:** Proposed  
**Authors:** <emil@jacero.se>  
**Tracking Issue:** emil-jacero/cue-oam#[TBD]  
**Related Roadmap Items:** Core Architecture, Component Model, Extensibility Framework  
**Reviewers:** [TBD]  
**Discussion:** GitHub Issue/PR #[TBD]  

## Objective

Establish a unified trait-based architecture where **everything is a trait**, organized into five fundamental categories. This design makes traits the single abstraction for all CUE-OAM functionality, from basic workloads to complex policies, with clear composition patterns and self-documenting metadata.

## Background

### Current State

CUE-OAM currently implements traits as building blocks for component functionality, but lacks:

- A unified categorization scheme for trait reusability
- Clear patterns for trait composition
- Self-documenting trait metadata
- Consistent trait application across different levels (component, scope, promise)

### Problem Statement

The current trait system faces several limitations:

1. **Unclear Composition**: No standard way to build complex traits from simpler ones
2. **Category Confusion**: Mixing of concerns (operational, governance, structural) without clear boundaries
3. **Limited Reusability**: Traits designed for one level can't easily be reused at others
4. **Discovery Challenges**: Hard to understand what traits exist and how they relate

### Goals

- [x] **Everything is a Trait**: Unify all functionality under the trait abstraction
- [x] **Five Core Categories**: Establish fundamental trait categories
- [x] **Self-Documenting Composition**: Make trait composition obvious from structure
- [x] **Maximum Reusability**: Enable traits to work across all appropriate levels
- [x] **Type-Safe Composition**: Leverage CUE's type system for validation

### Non-Goals

- Migration of existing traits (separate effort)
- Provider-specific implementations
- Runtime trait discovery mechanisms
- GUI/tooling implementation

## Proposal

### Core Trait Categories

All traits in CUE-OAM belong to one of eight fundamental categories:

```cue
#TraitDomain: "operational" | "structural" | "behavioral" | "resource" | "contractual" | "security" | "observability" | "integration"
```

1. **Operational** - How things execute (runtime behavior)
   - Examples: Workload, Task, CronJob, Scaling, Lifecycle

2. **Structural** - How things are organized and related
   - Examples: Network, Dependency, Topology, Service Discovery

3. **Behavioral** - How things act and react (logic and patterns)
   - Examples: Retry, CircuitBreaker, RateLimiter, Throttle, Strategy

4. **Resource** - What things have and need (state and data)
   - Examples: Volume, Config, Database, Secret, Cache

5. **Contractual** - What things must guarantee (constraints and policies)
   - Examples: Policy, SLA, Schema, Validation, Compliance

6. **Security** - How things are protected and controlled (authentication, authorization, encryption)
   - Examples: RBAC, NetworkPolicy, PodSecurityPolicy, ServiceAccount, Certificates

7. **Observability** - How things are monitored and understood (metrics, logs, tracing)
   - Examples: ServiceMonitor, PodMonitor, Logging, Tracing, HealthChecks

8. **Integration** - How things connect and communicate (service connectivity)
   - Examples: ServiceMesh, MessageQueue, EventSourcing, APIGateway

### Trait Metadata Structure

```cue
#TraitTypes: "atomic" | "composite" | "modifier" | "custom"
#TraitDomain: "operational" | "structural" | "behavioral" | "resource" | "contractual" | "security" | "observability" | "integration"
#TraitScopes: "component" | "scope"

#TraitMetaBase: {
    #apiVersion:      string | *"core.oam.dev/v2alpha2"
    #kind:            string
    #combinedVersion: "\(#apiVersion).\(#kind)"

    // Human-readable description of the trait
    description?: string

    // Optional metadata labels and annotations
    labels?:      #LabelsType
    annotations?: #AnnotationsType

    // The type of this trait
    // Can be one of "atomic", "composite", "modifier", "custom"
    type!: #TraitTypes

    // Where can this trait be applied
    // Can be one or more of "component", "scope"
    scope!: [...#TraitScopes]

    // Fields this trait provides to a component, scope, or promise
    provides!: {...}
    ...
}

#TraitMetaAtomic: #TraitMetaBase & {
    #apiVersion:      string
    #kind:            string
    #combinedVersion: "\(#apiVersion).\(#kind)"
    type:  "atomic"

    // The domain of this trait
    // Can be one of "operational", "structural", "behavioral", "resource", "contractual", "security", "observability", "integration"
    domain!: #TraitDomain

    requiredCapability?: string | *#combinedVersion
}
```

### Trait Composition Model

Traits are either **atomic** (fundamental building blocks) or **composite** (built from other traits):

#### Atomic Trait Example

```cue
#Workload: #Trait & {
    #metadata: #traits: Workload: {
        domain: "operational"
        provides: workload: #Workload.workload
        type: "atomic"
        requiredCapabilities: [
            "core.oam.dev/v2alpha1.Workload",
        ]
        scope: ["component"]
    }

    workload: {
        containers: [string]: {...}
        containers: main: {name: string | *#metadata.name}
    }
}

#Volume: #Trait & {
    #metadata: #traits: Volume: {
        domain: "resource"
        provides: volumes: #Volume.volumes
        type: "atomic"
        requiredCapabilities: [
            "core.oam.dev/v2alpha1.Volume",
        ]
        scope: ["component"]
    }

    // Volumes to be created
    volumes: [string]: {
        name!:      string
        type!:      "emptyDir" | "volume"
        mountPath!: string
        if type == "volume" {
            size?: string
        }
    }
    // Add a name field to each volume for easier referencing in volume mounts. The name defaults to the map key.
    for k, v in volumes {
        volumes: (k): v & {
            name: string | *k
        }
    }
}
```

#### Composite Trait Example

```cue
#Database: #Trait & {
    #metadata: #traits: Database: {
        type: "composite"
        domain: "operational"
        composes: [#Workload.#metadata.#traits.Workload, #Volume.#metadata.#traits.Volume]
        provides: database: #Database.database
        scope: ["component"]
        // requiredCapabilities: automatically computed from composed traits
    }

    database: {
        type:      "postgres" | "mysql"
        replicas?: uint | *1
        version:   string
        persistence: {
            enabled: bool | *true
            size:    string | *"10Gi"
        }
    }

    volumes: {if database.persistence.enabled {
        dbData: {
            type:      "volume"
            name:      "db-data"
            size:      database.persistence.size
            mountPath: string | *"/var/lib/data"
        }
    }}
    
    workload: #Workload.workload & {
        if database.type == "postgres" {
            containers: main: {
                name: "postgres"
                image: {
                    registry: "docker.io/library/postgres"
                    tag:      database.version
                }
                ports: [{
                    name:          "postgres"
                    protocol:      "TCP"
                    containerPort: 5432
                }]
                if database.persistence.enabled {
                    volumeMounts: [volumes.dbData & {mountPath: "/var/lib/postgresql/data"}]
                }
                env: "POSTGRES_DB": {name: "POSTGRES_DB", value: #metadata.name}
            }
        }
        if database.type == "mysql" {
            containers: main: {
                name: "mysql"
                image: {
                    registry: "docker.io/library/mysql"
                    tag:      database.version
                }
                ports: [{
                    name:          "mysql"
                    protocol:      "TCP"
                    containerPort: 3306
                }]
                if database.persistence.enabled {
                    volumeMounts: [volumes.dbData & {mountPath: "/var/lib/mysql"}]
                }
                env: "MYSQL_DATABASE": {name: "MYSQL_DATABASE", value: #metadata.name}
            }
        }
    }
}
```

### Key Features Implemented

1. **Automatic Requirement Computation**: Composite traits automatically compute requirements from their composed traits
2. **Validation with Error Messages**: Uses CUE's `error()` builtin for proper error handling
3. **Self-Documenting Structure**: `type` field explicitly declares `atomic`, `composite`, `modifier`, or `custom`.
4. **Name Population**: Trait names are automatically populated from the key in the `#traits` map
5. **Composition Depth Limiting**: Atomic traits at level 0, composite traits up to level 3
6. **Circular Dependency Detection**: Prevents traits from composing themselves directly or indirectly

### Trait Classification System

Understanding the different trait classifications is crucial for building effective CUE-OAM applications. Each classification serves a specific purpose in the architecture:

#### Atomic Traits

**Purpose**: Fundamental building blocks that provide single, focused capabilities.

**Characteristics**:

- Self-contained functionality with no dependencies on other traits
- Directly map to provider implementations
- Cannot be decomposed further
- Composition depth of 0

**When to use**: When you need a basic capability that doesn't require other traits to function.

**Example**: `#Volume`, `#Secret`, `#Replica` - these provide specific functionality without needing other traits.

#### Composite Traits

**Purpose**: Higher-level abstractions built by combining multiple traits.

**Characteristics**:

- Compose 2 or more atomic or other composite traits
- Automatically inherit required capabilities from composed traits
- Maximum composition depth of 3 to prevent complexity
- Provide simplified interfaces for common patterns

**When to use**: When you want to package multiple related capabilities into a single, reusable abstraction.

**Example**: `#Database` composes `#Workload` and `#Volume` to create a complete database deployment pattern.

#### Modifier Traits

**Purpose**: Enhance or modify existing resources without creating primary resources themselves.

**Characteristics**:

- Applied to existing components or resources
- Can be safely ignored by providers that don't support them
- Often provide cross-cutting concerns (monitoring, security policies)
- Don't create standalone resources

**When to use**: When adding optional enhancements that shouldn't break if unsupported.

**Example**: `#RateLimiter`, `#CircuitBreaker` - these modify behavior but don't create primary resources.

#### Custom Traits

**Purpose**: Last-resort mechanism for platform engineers to implement organization-specific or proprietary functionality that cannot be achieved through standard composition patterns.

**Characteristics**:

- Designed as an escape hatch for edge cases and proprietary integrations
- Can target completely different APIs or platforms outside the standard OAM model
- Follow the same `#TraitObject` structure but with relaxed composition rules
- May bypass standard validation for compatibility with external systems
- Can be atomic or composite-like without strict adherence to composition patterns
- Support optional `requiredCapabilities` for custom provider requirements

**When to use**:

- When integrating with proprietary or legacy systems that don't fit the OAM model
- When standard composition patterns are insufficient for complex business logic
- When you need to wrap external APIs that have fundamentally different resource models
- As a temporary solution while proper traits are being developed

**Example**:

- A `#LegacyMainframe` trait that interfaces with IBM z/OS systems
- A `#CloudProviderSpecific` trait using proprietary AWS/Azure/GCP APIs
- A `#PaymentGateway` trait integrating with third-party payment processors

**Important**: Custom traits should be used sparingly. Before creating a custom trait, always attempt to:

1. Use existing atomic traits
2. Compose standard traits
3. Extend standard traits with additional fields
Only resort to custom traits when these approaches are genuinely insufficient.

#### Classification Guidelines

1. **Start with Atomic**: Build atomic traits for fundamental capabilities
2. **Compose for Patterns**: Create composite traits for common usage patterns
3. **Modify Carefully**: Use modifier traits for optional enhancements
4. **Custom as Last Resort**: Only create custom traits when standard patterns truly cannot meet requirements

The classification system ensures:

- **Clarity**: Clear understanding of what each trait does and how it behaves
- **Reusability**: Traits can be combined in predictable ways
- **Provider Compatibility**: Providers know which traits are essential vs optional
- **Maintainability**: Limited composition depth prevents unmaintainable complexity
- **Flexibility**: Custom traits provide an escape hatch for edge cases

### Extending Traits in Components

While traits have fixed schemas, CUE-OAM provides flexibility for developers to extend trait functionality at the component level without modifying the trait definitions themselves.

#### Extending Composite Traits

When using composite traits in a component, developers can directly access and extend the underlying atomic traits:

```cue
// Using a Database composite trait but adding custom volumes
myDatabase: #Component & {

    // The normal trait fields
    #Database
    database: {
        type: "postgres"
        version: "15"
    }

    // You can modify the fields of the atomic traits like this,
    // as long as the modifications does not collide with the begavior of the trait.
    containerSet: {
        containers: logging: {
            image: {
                repository: "company/best-logging-container"
                tag:        "1337"
            }
        }
    }
}
```

#### Extending Atomic Traits

Most atomic traits are designed with extensibility in mind through named structs:

```cue
// Atomic traits typically use named maps for resources
myComponent: #Component & {
    #Volume
    volumes: {
        // Standard volumes
        appData: {
            type: "volume"
            size: "10Gi"
            mountPath: "/data"
        }
        // Add any number of additional volumes
        cache: {
            type: "emptyDir"
            mountPath: "/cache"
        }
        temp: {
            type: "emptyDir"
            mountPath: "/tmp"
        }
    }

    #Secret
    secrets: {
        // Add multiple secrets as needed
        apiKeys: {
            name: "api-keys"
            data: {...}
        }
        dbCredentials: {
            name: "db-creds"
            data: {...}
        }
    }
}
```

#### Extension Patterns

**1. Named Maps Pattern**: Most resource traits use `[string]: {...}` allowing unlimited named entries:

- `volumes: [string]: #VolumeSpec`
- `secrets: [string]: #SecretSpec`
- `configs: [string]: #ConfigSpec`
- `containers: [string]: #ContainerSpec`

**2. Direct Field Access**: Composite traits expose their composed traits' fields:

- Access `database.volumes` to add storage
- Access `database.workload` to modify containers
- All composed trait fields remain accessible

**3. CUE Unification**: Extensions merge with defaults through CUE's unification:

```cue
// Trait provides defaults
// E.g. "name" defaults to the key
volumes: dataVolume: {
    type: "volume"
    size: "10Gi"
}

// Component extends
volumes: dataVolume: {
    size: "50Gi"  // Override size
    storageClass: "fast-ssd"  // Add new field
}
```

#### Best Practices for Extensions

1. **Preserve Trait Semantics**: Extensions should complement, not contradict, the trait's purpose
2. **Use Consistent Naming**: Follow the trait's naming conventions for added resources
3. **Document Extensions**: Comment why additional resources are needed
4. **Avoid Deep Nesting**: Keep extensions at the immediate trait level when possible
5. **Validate Compatibility**: Ensure extensions work with the target provider

This extensibility model provides flexibility while maintaining the benefits of structured traits, allowing developers to handle edge cases without creating custom traits for minor variations.

### Working Example

The current implementation includes working examples:

```cue
// Test composite trait that works correctly
testValidWebService: #TraitMetaComposite & {
    domain: "operational"
    scope: ["component"]
    composes: [
        testAtomicWorkload,
        testAtomicExposable, 
        testAtomicHealthCheck,
    ]
    provides: {
        workload: {}
        expose: {}
        health: {}
    }
}

// Computed requirements will be:
// ["core.oam.dev/v2alpha2.HealthCheck", "core.oam.dev/v2alpha2.Network", "core.oam.dev/v2alpha2.Runtime"]
```

## Benefits

1. **Unified Mental Model**: Everything is a trait - no special cases
2. **Maximum Reusability**: Traits work at any appropriate level
3. **Self-Documenting**: Structure itself shows atomic vs composite
4. **Type Safety**: CUE's type system ensures valid compositions
5. **Clear Categories**: Eight categories cover all use cases
6. **Natural Composition**: Complex traits built from simple ones
7. **Better Discovery**: Easy to find and understand traits
8. **Extensible**: New traits fit naturally into categories

## Testing

1. **Category Coverage**: Ensure all existing traits fit categories
2. **Composition Validation**: Test atomic and composite traits
3. **Level Compatibility**: Verify traits work at appropriate levels
4. **Composition Validation**: Test depth limits (atomic=0, max composite=3) and circular dependency detection

## Alternatives Considered

### More Categories

Having 10+ categories was considered but rejected as too complex. Eight categories provide sufficient organization without overwhelming users.

### Type Field Implementation

Initially considered making the type implicit based on presence/absence of `composes`, but explicit `type: "atomic" | "composite"` field was added for clarity and validation. This ensures traits explicitly declare their nature and enables proper validation.

### Inheritance Model

Traditional inheritance (`extends`) was considered but composition (`composes`) is clearer and more flexible.

## Open Questions

1. Should we enforce category-specific validation rules?
2. How should we handle complex composition chains with multiple levels?
3. Should certain category combinations be prohibited at an application level?
4. How do we handle trait versioning in compositions?
5. **DESIGN NEEDED: Incompatible Traits System** - Design a new implementation for handling trait incompatibilities. The previous `incompatibleTraits` field approach was removed to allow for a better design. Consider:
   - Should incompatibilities be declared at the trait level or component level?
   - How should incompatibilities work with trait composition?
   - Should incompatibilities be category-based, trait-specific, or both?
   - Should we support conditional incompatibilities based on configuration?

## Conclusion

This unified trait architecture makes CUE-OAM incredibly flexible while maintaining structure through eight fundamental categories. By making everything a trait with clear composition patterns, we achieve maximum reusability and a consistent mental model across the entire system. The self-documenting nature of the metadata structure ensures that traits are easy to understand, compose, and validate.
