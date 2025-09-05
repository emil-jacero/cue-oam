# CUE-OAM Design Document: Trait System Architecture

2025/01/09

**Status:** Draft
**Lifecycle:** Proposed
**Authors:** emil-jacero@
**Tracking Issue:** emil-jacero/cue-oam#[TBD]
**Related Roadmap Items:** Core Architecture, Component Model, Extensibility Framework
**Reviewers:** [TBD]
**Discussion:** GitHub Issue/PR #[TBD]

## Objective

Establish a unified trait-based architecture as the foundational abstraction for all CUE-OAM system components, enabling consistent composition, extensibility, and platform-agnostic application modeling. This design consolidates operational functionality, scopes, policies, and platform extensions under a single, coherent framework.

## Background

### Current State

CUE-OAM currently implements traits as the primary building blocks for component functionality, with existing implementations including:

- **Operational Traits**: `#Workload`, `#WebService`, `#Worker`, `#Task`, `#Database`
- **Storage and Data Traits**: `#Volume`, `#Config`, `#Secret`, `#ImagePullSecret`
- **Behavioral Traits**: `#Replicable`, `#Exposable`

These traits are defined in `/traits/standard/` and provide core functionality for containerized workloads, but the system lacks:

- A unified categorization scheme to allow traits to be reused elsewhere
- Standardized metadata for discovery and validation
- Clear composition patterns for complex scenarios

### Problem Statement

The current trait system, while functional, faces several limitations:

1. **Namespace Conflicts**: No isolation between different types of traits (operational vs. governance)
2. **Limited Discoverability**: No standardized way to understand trait capabilities and what traits exist
3. **Composition Complexity**: Unclear patterns for combining traits effectively
4. **Extension Challenges**: Difficult to add platform-specific or policy traits

Example (Composition Complexity):

```cue
// Base trait
#Workload: #ComponentTrait & {
    #metadata: #traits: Workload: {
        provides: workload: #Workload.workload
        requires: [
            "core.oam.dev/v2alpha1.Workload",
        ]
    }
    
    workload: {
        containers: [string]: #ContainerSpec
        containers: main: {name: string | *#metadata.name}
    }
}

// Extended trait
#Database: #ComponentTrait & {
    #metadata: #traits: Database: {
        provides: database: #Database.database
        requires: [
            "core.oam.dev/v2alpha1.Workload",
            "core.oam.dev/v2alpha1.Volume",
            "core.oam.dev/v2alpha1.Config",
        ]
        extends: [
            #Workload.#metadata.#traits.Workload,
            #Volume.#metadata.#traits.Volume,
            #Config.#metadata.#traits.Config
        ]
        category: "operational"
    }
    
    database: {
        type: "postgres" | "mysql" | "mongodb"
        replicas?: uint | *1
        version: string
        persistence: {
            enabled: bool | *true
            size: string | *"10Gi"
        }
    }
    
    // Automatically inherited fields
    // Makes sure the schemas are included
    for f in #metadata.#traits.Database.extends {
        f.provides
    }
}
```

### Goals

- [x] **Unified Architecture**: Establish traits as the single foundational abstraction
- [x] **Category System**: Implement trait categorization to prevent conflicts
- [x] **Rich Metadata**: Standardize metadata for discovery, validation, and tooling
- [x] **Composition Patterns**: Define clear patterns for trait combination and inheritance
- [x] **Extensibility**: Enable easy addition of new trait types and categories
- [ ] **Platform Integration**: Seamless mapping from traits to platform resources
- [ ] **Validation Framework**: Built-in validation for trait definitions and usage

### Non-Goals

- Replacing existing trait implementations (maintain backward compatibility)
- Creating trait-specific DSLs (leverage CUE's native capabilities)
- Platform-specific trait optimizations (keep traits platform-agnostic, for now)
- Runtime trait modification (focus on design-time composition)

## Proposal

### CUE-OAM Model Impact

This design establishes traits as the universal building block across the entire CUE-OAM hierarchy:

- **New Traits**: Introduce trait categories and enhanced metadata system. Simplify inheritance and schema management
- **Component Changes**: Components become aggregators of categorized traits
- **Application Changes**: Applications can define scope and policy traits alongside components
- **Scope/Policy Integration**: Scopes and policies become specialized trait categories
- **Provider Requirements**: Providers must handle all trait categories and their mappings

### Core Trait Definition

The foundational trait structure provides a consistent base for all system components:

```cue
#TraitCategory: string | "component" | "scope" | "policy" | "bundle"

#TraitsMeta: {
    // Category designation
    category!: #TraitCategory

    // Which fields this trait adds to a parent component, scope or policy.
    // Must be a list of CUE paths, e.g. workload: #Workload.workload
    provides!: [string]: {...}

    // Platform capabilities required by this trait to function.
    // Used to ensure that the target platform supports the trait.
    requires!: [...string]

    // Optionally, which trait this trait extends
    extends?: [...#TraitsMeta]

    // Optional short description of the trait
    description?: string

    ...
}

#Trait: {
    #metadata: {
        #id:  #NameType
        name: #NameType | *#id
        #traits: [string]: #TraitsMeta
        ...
    }

    // Trait-specific fields
    ...
}
```

### Category-Specific Extensions

Each trait category extends the base with specific metadata:

```cue
#ComponentTrait: #Trait & {
    #metadata: {
        #id:  #NameType
        name: #NameType | *#id
        #traits: [string]: #TraitsMeta & {
            category: "component"
        }
    }
    ...
}

#ScopeTrait: #Trait & {
    #metadata: {
        #id:          #NameType
        name:         #NameType | *#id
        #traits: [string]: #TraitsMeta & {
            category: "scope"
        }
    }
    ...
}

#PolicyTrait: #Trait & {
    #metadata: {
        #id:  #NameType
        name: #NameType | *#id
        #traits: [string]: #TraitsMeta & {
            category: "policy"
        }
    }
    ...
}

#BundleTrait: #Trait & {
    #metadata: {
        #id:  #NameType
        name: #NameType | *#id
        #traits: [string]: #TraitsMeta & {
            category: "bundle"
        }
    }
    ...
}
```

### Trait Composition Patterns

#### Inheritance

```cue
// Base trait
#Workload: #ComponentTrait & {
    #metadata: #traits: Workload: {
        provides: workload: #Workload.workload
        requires: [
            "core.oam.dev/v2alpha1.Workload",
        ]
    }
    
    workload: {
        containers: [string]: #ContainerSpec
        containers: main: {name: string | *#metadata.name}
    }
}

// Extended trait
#Database: #ComponentTrait & {
    #metadata: #traits: Database: {
        provides: database: #Database.database
        requires: [
            "core.oam.dev/v2alpha1.Workload",
            "core.oam.dev/v2alpha1.Volume",
            "core.oam.dev/v2alpha1.Config",
        ]
        extends: [
            #Workload.#metadata.#traits.Workload,
            #Volume.#metadata.#traits.Volume,
            #Config.#metadata.#traits.Config
        ]
        category: "operational"
    }
    
    database: {
        type: "postgres" | "mysql" | "mongodb"
        replicas?: uint | *1
        version: string
        persistence: {
            enabled: bool | *true
            size: string | *"10Gi"
        }
    }
    
    // Automatically inherited fields
    // Makes sure the schemas are included
    for f in #metadata.#traits.Database.extends {
        f.provides
    }
}
```

### Provider Integration

Providers translate traits to platform-specific resources based on category:

```cue
#KubernetesProvider: {
    // Handle operational traits
    component: {
        "Workload": #WorkloadTransformer
        "WebService": #WebServiceTransformer
        "Database": #DatabaseTransformer
        "Volume": #VolumeTransformer
        "Config": #ConfigTransformer
        "Secret": #SecretTransformer
    }
    
    // Handle scope traits
    scope: {
        "NetworkScope": #NetworkPolicyTransformer
        "ResourceScope": #ResourceQuotaTransformer
        "SecurityScope": #PodSecurityTransformer
    }
    
    // Handle policy traits
    policy: {
        "SecurityPolicy": #ValidatingWebhookTransformer
        "ResourcePolicy": #MutatingWebhookTransformer
        "CompliancePolicy": #PolicyReportTransformer
    }
    
    // Handle bundle traits (TBD)
    bundle: {
        // Bundle-specific traits to be defined
    }
}
```

### Validation Framework

Built-in validation ensures trait correctness:

```cue
```

## Implementation Plan

### Phase 1: Core Architecture (In Progress)

- [x] Define base `#Trait` structure
- [x] Implement trait categorization system
- [ ] Establish metadata standards
- [ ] Update existing operational traits. Organize into different packages.
- [ ] Add conflict resolution for overlapping traits

```shell
/
├── traits
│   ├── schema ## The standard schema that will be referenced in all traits
│   ├── component ## The component traits
│   ├── scope ## The scope traits
│   ├── policy ## The policy traits
│   └── bundle ## The bundle traits
```

### Phase 2: Scope Integration (Planned)

- [ ] Implement scope traits (`#NetworkScope`, `#ResourceScope`)
- [ ] Define scope-component relationship patterns
- [ ] Update applications to support scope traits
- [ ] Add provider support for scope traits

### Phase 3: Policy Integration (Planned)

- [ ] Implement policy trait framework
- [ ] Integrate existing well known tools. Like OPA and Kyverno.
- [ ] Define policy targeting and rule systems
- [ ] Add validation and enforcement mechanisms
- [ ] Integrate with existing governance tools

### Phase 5: Advanced Features (Future)

- [ ] Trait composition validation

## Alternatives Considered

### Separate Abstraction Layers

**Alternative**: Keep scopes, policies, and extensions as separate abstractions
**Rejected**: Would fragment the system and create inconsistent patterns and a lot more work

### Trait Namespacing

**Alternative**: Use CUE packages for trait organization instead of categories
**Rejected**: Categories provide better runtime behavior and clearer semantics. Although the traits categories should be separated into different packages for organisational sake.

### Dynamic Trait System

**Alternative**: Runtime trait modification and hot-swapping
**Rejected**: Adds complexity without clear benefits for the target use cases. Plus we want to utilize CUE fully.

## Future Considerations

### Trait Ecosystem

- Community-contributed trait marketplace. Distributed as CUE modules (OCI artifacts)
- Trait discovery and recommendation systems. Using a CLI tool
- Cross-organization trait sharing standards. By following the same api naming standard.

### Advanced Composition

- Trait dependency resolution
- Automatic trait selection based on requirements
- Conflict resolution for overlapping traits
- Performance optimization for large trait compositions

### Tooling Integration

- IDE support for trait development
- Visual trait composition tools. Maybe :-)
- Automated documentation generation. Using CUE
- Testing frameworks for trait validation. Using CUE

## Related Work

- **Kubernetes Operators**: Inspiration for extension traits
- **OPA/Gatekeeper**: Policy enforcement patterns
- **Helm Charts**: Composition and templating concepts
- **Timoni**: Composition and bundling of applications
- **Crossplane**: Provider abstraction models
