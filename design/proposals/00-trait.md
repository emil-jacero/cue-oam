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
- Consistent trait application across different levels (component, application, scope, bundle, promise)

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

All traits in CUE-OAM belong to one of five fundamental categories:

```cue
#TraitCategory: "operational" | "structural" | "behavioral" | "resource" | "contractual"
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
   - Examples: Policy, SLA, Schema, Validation, Security, Compliance

### Trait Metadata Structure

```cue
#TraitMeta: {
    name: #NameType

    // What kind of trait this is, based on where it can be applied
    scope: [...#TraitScope]

    // Primary category - what this trait mainly does
    category: #TraitCategory
    
    // Composition - list of traits this trait is built from
    // Presence of this field makes it a composite trait
    // Absence makes it an atomic trait
    composes?: [...#TraitMeta]
    
    // fields this trait provides to a component, application, scope, bundle, or promise
    provides: {...}
    
    // External dependencies (not composition)
    // For atomic traits: manually specified
    // For composite traits: automatically computed from composed traits
    requires?: [...string]
    
    // Computed requirements for composite traits
    #computedRequires: {
        if composes == _|_ {
            // Atomic trait - use manually specified requires
            if requires == _|_ {
                out: []
            }
            if requires != _|_ {
                out: requires
            }
        }
        if composes != _|_ {
            if len(composes) == 0 {
                // Empty composes list - treat as atomic
                if requires == _|_ {
                    out: []
                }
                if requires != _|_ {
                    out: requires
                }
            }
            if len(composes) > 0 {
                // Composite trait - compute from composed traits
                allRequirements: list.FlattenN([
                    for composedTrait in composes {
                        composedTrait.#computedRequires.out
                    }
                ], 1)
                
                // Deduplicate requirements using unique list pattern
                deduped: [ for i, x in allRequirements if !list.Contains(list.Drop(allRequirements, i+1), x) {x}]
                
                // Sort the deduplicated requirements
                out: list.Sort(deduped, list.Ascending)
            }
        }
    }
    
    // Validation: composite traits should not manually specify requires
    if composes != _|_ {
        if len(composes) > 0 && requires != _|_ {
            error("Composite traits should not manually specify 'requires' - they are computed automatically")
        }

        // Validation: composite traits can only compose atomic traits
        if len(composes) > 0 {
            for i, composedTrait in composes {
                // Each composed trait must be atomic (no composes field or empty composes)
                if (composedTrait.composes & [...]) != _|_ {
                    if len(composedTrait.composes & [...]) > 0 {
                        error("Composite trait can only compose atomic traits. Trait at index \(i) is composite (has composes field)")
                    }
                }
            }
        }
    }
}

#TraitScope: "component" | "scope" | "bundle" | "promise"
```

### Trait Composition Model

Traits are either **atomic** (fundamental building blocks) or **composite** (built from other traits):

#### Atomic Trait Example

```cue
#Workload: #Trait & {
    #metadata: #traits: Workload: {
        category: "operational"
        provides: workload: #Workload.workload
        requires: [
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
        category: "resource"
        provides: volumes: #Volume.volumes
        requires: [
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
        category: "operational"
        composes: [#Workload.#metadata.#traits.Workload, #Volume.#metadata.#traits.Volume]
        provides: database: #Database.database
        scope: ["component"]
        // requires: automatically computed from composed traits
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

    // Inherited fields. Useful for validation or defaults.
    for t in #metadata.#traits.Database.composes {
        t.provides
    }
}
```

### Trait Validation

The validation is built into the `#TraitMeta` structure using CUE's `error()` builtin:

```cue
// Built into #TraitMeta - automatic validation

// Validation: composite traits should not manually specify requires
if composes != _|_ {
    if len(composes) > 0 && requires != _|_ {
        error("Composite traits should not manually specify 'requires' - they are computed automatically")
    }

    // Validation: composite traits can only compose atomic traits
    if composes != _|_ && len(composes) > 0 {
        for i, composedTrait in composes {
            // Each composed trait must be atomic (no composes field or empty composes)
            if (composedTrait.composes & [...]) != _|_ {
                if len(composedTrait.composes & [...]) > 0 {
                    error("Composite trait can only compose atomic traits. Trait at index \(i) is composite (has composes field)")
                }
            }
        }
    }
}
```

### User Experience

Users work with traits at different levels naturally:

```cue
// Component level - compose traits to build components
myService: #Component & {
    #metadata: name: "api-service"

    #WebService
    workload: containers: main: image: "myapp:v1.0"
    expose: port: 8080

    #Database
    database: {
        engine: "postgres"
        version: "14"
    }

    #Metrics
    metrics: {
        endpoints: ["/metrics"]
    }
}

// Application level - apply traits to entire applications
myApp: #Application & {
    name: "my-application"
    components: {
        api: myService
    }
    scopes: {
        #NetworkIsolationScope
        network: {
            components: [components.api]
            // Network isolation level
            isolation: "none" | "namespace" | "pod" | "strict" | *"namespace"
            
            // Ingress/egress policies
            ingress?: [...#NetworkPolicyRule]
            egress?: [...#NetworkPolicyRule]
            
            // Service mesh configuration
            serviceMesh?: {
                enabled: bool | *false
                profile?: "strict" | "permissive" | *"permissive"
                mTLS?: bool | *true
            }
            
            // DNS configuration
            dns?: {
                policy?: "ClusterFirst" | "ClusterFirstWithHostNet" | "Default"
                search?: [...string]
                options?: [...#DNSOption]
            }
        }
    }
    policies: {
        #SecurityPolicy // contractual trait
        securityPolicy: {
            podSecurity: "restricted"
        }

        #ResourceQuotaPolicy // contractual trait
        resourceQuota: {
            limits: {
                cpu: "1000"
                memory: "1000Gi"
            }
        }
    }
}
```

### Key Features Implemented

1. **Automatic Requirement Computation**: Composite traits automatically compute requirements from their composed traits
2. **Deduplication and Sorting**: Requirements are deduplicated using CUE's unique list pattern and sorted alphabetically
3. **Validation with Error Messages**: Uses CUE's `error()` builtin for proper error handling
4. **Self-Documenting Structure**: Presence of `composes` field indicates composite trait
5. **Name Population**: Trait names are automatically populated from the key in the `#traits` map

### Working Example

The current implementation includes working examples:

```cue
// Test composite trait that works correctly
testValidWebService: #TraitMeta & {
    category: "operational"
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
    scope: ["component"]
}

// Computed requirements will be:
// ["core.oam.dev/v2alpha1.HealthProvider", "core.oam.dev/v2alpha1.NetworkProvider", "core.oam.dev/v2alpha1.Runtime"]
```

## Benefits

1. **Unified Mental Model**: Everything is a trait - no special cases
2. **Maximum Reusability**: Traits work at any appropriate level
3. **Self-Documenting**: Structure itself shows atomic vs composite
4. **Type Safety**: CUE's type system ensures valid compositions
5. **Clear Categories**: Five categories cover all use cases
6. **Natural Composition**: Complex traits built from simple ones
7. **Better Discovery**: Easy to find and understand traits
8. **Extensible**: New traits fit naturally into categories

## Testing

1. **Category Coverage**: Ensure all existing traits fit categories
2. **Composition Validation**: Test atomic and composite traits
3. **Level Compatibility**: Verify traits work at appropriate levels
4. **Cycle Detection**: Ensure no circular dependencies

## Alternatives Considered

### More Categories

Having 10+ categories was considered but rejected as too complex. Five categories provide sufficient organization without overwhelming users.

### Explicit Composition Field

Adding a `composition: "atomic" | "composite"` field was considered but rejected as redundant - the presence/absence of `composes` is self-documenting.

### Inheritance Model

Traditional inheritance (`extends`) was considered but composition (`composes`) is clearer and more flexible.

## Open Questions

1. Should we enforce category-specific validation rules?
2. How deep should composition be allowed to go? Right now it is forced at 0.
3. Should certain category combinations be prohibited at an application level?
4. How do we handle trait versioning in compositions?

## Conclusion

This unified trait architecture makes CUE-OAM incredibly flexible while maintaining structure through five fundamental categories. By making everything a trait with clear composition patterns, we achieve maximum reusability and a consistent mental model across the entire system. The self-documenting nature of the metadata structure ensures that traits are easy to understand, compose, and validate.
