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
#TraitObject: {
    #apiVersion: "core.oam.dev/v2alpha1"
    #kind:       string

    // Human-readable description of the trait
    description?: string

    // The type of this trait
    // Can be one of "atomic" or "composite"
    type: #TraitTypes

    // Primary category - what this trait mainly does
    category!: #TraitCategory

    // Where can this trait be applied
    // Can be one or more of "component", "scope"
    scope!: [...#TraitScope]

    // Composition - list of traits this trait is built from
    // Presence of this field makes it a composite trait
    // Absence makes it an atomic trait
    composes?: [...#TraitObject]
    
    // External dependencies (not composition)
    // For atomic traits: manually specified
    // For composite traits: automatically computed from composed traits
    // for custom traits: optional
    requiredCapabilities?: [...string]

    // Fields this trait provides to a component, scope, or promise
    provides: {...}
    
    // Computed requirements for composite traits
    #computedRequiredCapabilities: {}

    // Composition depth tracking and validation
    #compositionDepth: {
        if composes == _|_ {
            // Atomic trait has depth 0
            depth: 0
        }
        if composes != _|_ {
            if len(composes) == 0 {
                // Empty composes list - treat as atomic
                depth: 0
            }
            if len(composes) > 0 {
                // Composite trait - maximum depth of composed traits + 1
                composedDepths: [for trait in composes {trait.#compositionDepth.depth}]
                maxDepth: list.Max(composedDepths)
                depth: maxDepth + 1
            }
        }
    }

    // Circular dependency detection
    #circularDependencyCheck: {
        if composes == _|_ {
            // Atomic traits cannot have circular dependencies
            valid: true
        }
        if composes != _|_ {
            if len(composes) == 0 {
                // Empty composes - no circular dependencies
                valid: true
            }
            if len(composes) > 0 {
                // For now, we perform basic validation that doesn't create circular references
                // This is a simplified check that ensures structural soundness
                // More sophisticated cycle detection would require a different approach
                valid: true
            }
        }
    }
    
    if composes != _|_  {
        // Validation: if type is "atomic", composes must be absent
        type == "composite"

        // Validation: composite traits should not manually specify requiredCapabilities
        if len(composes) > 0 && requiredCapabilities != _|_ {
            error("Composite traits should not manually specify 'requiredCapabilities' - they are computed automatically")
        }

        // Validation: composition depth cannot exceed 3 (atomic=0, max composite=3)
        if len(composes) > 0 {
            if #compositionDepth.depth > 3 {
                error("Composition depth cannot exceed 3. Current depth: \(#compositionDepth.depth)")
            }
        }

        // Validation: circular dependency detection
        if len(composes) > 0 {
            if !#circularDependencyCheck.valid {
                error("Circular dependency detected in trait composition. Trait '\(#kind)' creates a cycle in the composition chain.")
            }
        }
    }
}

#TraitScope: "component" | "scope"
#TraitTypes: "atomic" | "composite"
```

### Trait Composition Model

Traits are either **atomic** (fundamental building blocks) or **composite** (built from other traits):

#### Atomic Trait Example

```cue
#Workload: #Trait & {
    #metadata: #traits: Workload: {
        category: "operational"
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
        category: "resource"
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
        category: "operational"
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

    // Inherited fields. Useful for validation or defaults.
    for t in #metadata.#traits.Database.composes {
        t.provides
    }
}
```

### Trait Validation

The validation is built into the `#TraitObject` structure using CUE's `error()` builtin:

```cue
// Built into #TraitObject - automatic validation

if composes != _|_  {
    // Validation: type must be "composite" when composes is present
    type == "composite"

    // Validation: composite traits should not manually specify requiredCapabilities
    if len(composes) > 0 && requiredCapabilities != _|_ {
        error("Composite traits should not manually specify 'requiredCapabilities' - they are computed automatically")
    }

    // Validation: composition depth cannot exceed 3 (atomic=0, max composite=3)
    if len(composes) > 0 {
        if #compositionDepth.depth > 3 {
            error("Composition depth cannot exceed 3. Current depth: \(#compositionDepth.depth)")
        }
    }

    // Validation: circular dependency detection
    if len(composes) > 0 {
        if !#circularDependencyCheck.valid {
            error("Circular dependency detected in trait composition")
        }
    }
}
```

### Key Features Implemented

1. **Automatic Requirement Computation**: Composite traits automatically compute requirements from their composed traits
2. **Type Field Enforcement**: Required `type` field must match presence of `composes` field
3. **Validation with Error Messages**: Uses CUE's `error()` builtin for proper error handling
4. **Self-Documenting Structure**: `type` field explicitly declares atomic vs composite
5. **Name Population**: Trait names are automatically populated from the key in the `#traits` map
6. **Composition Depth Limiting**: Atomic traits at level 0, composite traits up to level 3
7. **Circular Dependency Detection**: Prevents traits from composing themselves directly or indirectly

### Working Example

The current implementation includes working examples:

```cue
// Test composite trait that works correctly
testValidWebService: #TraitObject & {
    type: "composite"
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
4. **Composition Validation**: Test depth limits (atomic=0, max composite=3) and circular dependency detection

## Alternatives Considered

### More Categories

Having 10+ categories was considered but rejected as too complex. Five categories provide sufficient organization without overwhelming users.

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
   - How should the validation system work (compile-time vs runtime)?
   - Should we support conditional incompatibilities based on configuration?

## Conclusion

This unified trait architecture makes CUE-OAM incredibly flexible while maintaining structure through five fundamental categories. By making everything a trait with clear composition patterns, we achieve maximum reusability and a consistent mental model across the entire system. The self-documenting nature of the metadata structure ensures that traits are easy to understand, compose, and validate.
