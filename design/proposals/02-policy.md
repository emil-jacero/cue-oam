# CUE-OAM Design Document: Multi-Level Policy Traits

2025/01/06

**Status:** Incoherent Rambling
**Lifecycle:** Ideation
**Authors:** <emil@jacero.se>
**Tracking Issue:** emil-jacero/opm#[TBD]
**Related Roadmap Items:** Policy System, Trait Architecture, Multi-Level Application Model  
**Reviewers:** [TBD]
**Discussion:** GitHub Issue/PR #[TBD]

## Objective

Enable cross-cutting organizational requirements, security standards, and governance rules through a flexible policy system that operates at Promise, Bundle, Scope, Application, and Component levels while maintaining reusability and clear validation semantics.

## Background

### Current State

CUE-OAM currently has:

- A trait-based architecture where policies exist as placeholders (`#Policy` in `scope.cue:52-56`)
- Multi-level application model (Promise, Bundle, Scope, Application, Component)
- Provider-based transformation system for implementing platform-specific behavior
- No unified policy enforcement mechanism across levels

### Problem Statement

Organizations need to enforce policies at different granularities:

- Platform teams need promise-level policies for template compliance
- DevOps teams need bundle-level policies for distribution control
- Security teams need scope-level policies for environment isolation
- Application teams need app-level policies for service boundaries
- Developers need component-level policies for fine-grained control

Currently, there's no coherent way to define, validate, and resolve policies across these levels.

### Goals

- [x] Design policies as specialized traits with "policy" category
- [x] Enable policy application at all five levels of the model
- [x] Provide clear validation of policy-level compatibility
- [x] Define conflict resolution strategies
- [x] Maintain reusability across different levels

### Non-Goals

- Implementation of specific policy engines (OPA, Kyverno, etc.)
- Runtime policy enforcement mechanisms
- Policy distribution/syndication systems
- GUI/tooling for policy management

## Proposal

### CUE-OAM Model Impact

**New Traits:**

- `#PolicyTrait` base definition with level validation
- Category-specific policies (Security, Resource, Governance, etc.)

**Component Changes:**

- Components can have policy traits alongside operational traits

**Application Changes:**

- Applications can define app-wide policies affecting all components

**Scope/Policy Integration:**

- Scopes enforce policies on all contained components
- Bundle policies manage distribution and deployment as a unit

**Provider Requirements:**

- Transform policies to platform-specific implementations (admission controllers, IAM, etc.)

### User Experience

```cue
// Policy definition with explicit level support
#NamingPolicy: #PolicyTrait & {
    #metadata: #traits: NamingPolicy: {
        category: "policy"
        // Policy author explicitly defines supported levels
        supportedLevels: ["promise", "bundle", "scope", "application", "component"]
    }
    
    // Base configuration for all levels
    base: {
        pattern: string
        enforceCase: "lower" | "upper" | "camel" | "snake"
    }
    
    // Level-specific templates
    levels: {
        promise?: {
            resourcePrefix: string
            includePromiseName: bool | *true
        }
        bundle?: {
            bundleIdentifier: string
            versionPattern: string | *"v[0-9]+\\.[0-9]+\\.[0-9]+"
        }
        scope?: {
            environmentSuffix: string
            teamIdentifier?: string
        }
        application?: {
            serviceBoundary: string
            includeAppName: bool | *true
        }
        component?: {
            strictMode: bool | *false
            allowOverride: bool | *false
        }
    }
}

// Usage at different levels
myScope: #Scope & {
    policies: [
        #NamingPolicy & {
            base: {
                pattern: "^[a-z][a-z0-9-]*$"
                enforceCase: "lower"
            }
            levels: scope: {
                environmentSuffix: "-prod"
                teamIdentifier: "platform"
            }
        }
    ]
}

myApp: #Application & {
    policies: [
        #ResourceQuotaPolicy & {
            levels: application: {
                perAppLimits: {
                    maxReplicas: 10
                    maxCPU: "4000m"
                    maxMemory: "8Gi"
                }
            }
        }
    ]
}
```

### Design Details

#### Policy Level Validation

Each policy must declare its supported levels, enabling:

- **Compile-time validation** when policies are attached at unsupported levels
- **Clear error messages** guiding users to correct usage
- **Evolution path** where adding level support is an explicit change

```cue
#PolicyTrait: {
    #metadata: {
        #traits: [string]: {
            category: "policy"
            supportedLevels: [...("promise" | "bundle" | "scope" | "application" | "component")]
        }
    }
    
    #validate: {
        level: "promise" | "bundle" | "scope" | "application" | "component"
        
        if !list.Contains(#metadata.#traits[_].supportedLevels, level) {
            error: "Policy does not support level: \(level)"
        }
    }
}
```

#### Conflict Resolution

When the same policy exists at multiple levels:

```cue
#PolicyConflictResolution: {
    strategy: "most-restrictive" | "most-specific" | "level-defined"
    
    // Policies can define their own resolution
    levelResolution?: {
        strategy: "merge" | "override" | "accumulate"
        mergeRules?: {
            arrays: "append" | "union" | "replace"
            objects: "deep" | "shallow"
            conflicts: "error" | "higher-wins" | "lower-wins"
        }
    }
    
    // Default priority order
    defaultPriority: [
        {level: "component", weight: 100},   // Highest
        {level: "application", weight: 80},
        {level: "scope", weight: 60},
        {level: "bundle", weight: 40},
        {level: "promise", weight: 20},      // Lowest
    ]
}
```

#### Policy Categories

Different policy types with different level support patterns:

**Governance Policies** (all levels)

- Naming conventions
- Labeling requirements
- Documentation standards

**Security Policies** (scope, component)

- Pod security standards
- Network segmentation
- RBAC rules

**Resource Policies** (all levels)

- CPU/Memory limits
- Storage quotas
- Scaling boundaries

**Distribution Policies** (bundle-specific)

- Version constraints
- Registry restrictions
- Signature requirements

**Compliance Policies** (scope, bundle)

- Data residency
- Audit logging
- Regulatory requirements

### Example Implementations

#### Multi-Level Resource Policy

```cue
#ResourceQuotaPolicy: #PolicyTrait & {
    #metadata: #traits: ResourceQuotaPolicy: {
        category: "policy"
        supportedLevels: ["promise", "bundle", "scope", "application", "component"]
    }
    
    base: {
        enforcement: "strict" | "soft" | "warn"
    }
    
    levels: {
        promise?: {
            maxTotalCPU: string
            maxTotalMemory: string
            maxInstances: int
        }
        bundle?: {
            maxComponentCount: int
            totalResourceLimit: {...}
        }
        scope?: {
            namespaceQuota: {
                cpu: string
                memory: string
                persistentVolumeClaims: int
            }
        }
        application?: {
            perAppLimits: {
                maxReplicas: int
                maxCPU: string
                maxMemory: string
            }
        }
        component?: {
            resources: {
                requests: {cpu: string, memory: string}
                limits: {cpu: string, memory: string}
            }
        }
    }
}
```

#### Limited-Level Security Policy

```cue
#DataResidencyPolicy: #PolicyTrait & {
    #metadata: #traits: DataResidencyPolicy: {
        category: "policy"
        // Only makes sense at certain levels
        supportedLevels: ["scope", "bundle"]
    }
    
    levels: {
        scope?: {
            allowedRegions: [...string]
            dataClassification: "public" | "internal" | "confidential" | "restricted"
            encryptionRequired: bool | *true
        }
        bundle?: {
            allowedRegistryRegions: [...string]
            crossRegionReplication: bool | *false
        }
        // Promise, application, and component levels intentionally unsupported
    }
}
```

### Testing

1. **Unit Tests**: Validate policy level compatibility checks
2. **Integration Tests**: Test policy inheritance and conflict resolution
3. **Provider Tests**: Ensure policies transform correctly to platform-specific implementations
4. **User Journey Tests**: Validate end-to-end policy application scenarios

### Migration

Since policies currently exist only as placeholders:

1. Implement `#PolicyTrait` base in core
2. Migrate existing `#Policy` references to new structure
3. Provide examples and documentation
4. No breaking changes for existing deployments

## Alternatives Considered

### Alternative 1: Universal Policies

Single policy definition that adapts behavior based on attachment point.

- **Pros**: Single source of truth
- **Cons**: Complex, hard to reason about

### Alternative 2: Level-Specific Policy Types

Separate policy types for each level (`#PromisePolicy`, `#ScopePolicy`, etc.)

- **Pros**: Clear separation
- **Cons**: Code duplication, harder to share logic

### Alternative 3: Policy Inheritance Only

Policies only defined at higher levels and inherited down.

- **Pros**: Simple mental model
- **Cons**: Lacks flexibility for level-specific needs

## Open Questions

1. **Policy Composition**: Should policies be composable from other policies?
2. **Versioning**: How to handle policy evolution when level support changes?
3. **Exceptions**: Per-level exception handling vs global exceptions?
4. **Observability**: How to track which policies affected a resource?
5. **Performance**: Impact of level validation on evaluation time?
6. **Partial Support**: Handling gaps in level support (e.g., supports A and C but not B)?
7. **Bundle Semantics**: Bundle policy behavior when components deployed individually?
8. **Provider Portability**: Same policy across different providers?

## Implementation Phases

**Phase 1: Foundation**

- Implement base `#PolicyTrait` with level validation
- Create validation framework

**Phase 2: Core Policies**

- Implement Security, Resource, and Naming policies
- Add multi-level support examples

**Phase 3: Conflict Resolution**

- Build inheritance and merge mechanisms
- Implement priority system

**Phase 4: Provider Integration**

- Transform policies to Kubernetes admission controllers
- Support cloud provider IAM policies

**Phase 5: Advanced Features**

- Policy composition
- Exception handling
- Observability integration

## Conclusion

This design provides a flexible yet structured approach to multi-level policies in CUE-OAM. By requiring policies to explicitly declare their supported levels, we achieve:

- **Clear contracts** between policy authors and users
- **Better error messages** when policies are misapplied  
- **Evolution paths** for adding level support
- **Provider flexibility** while maintaining consistent interfaces

The key insight is that **constraints liberate**: by limiting where policies can be applied, we increase their usefulness and reliability. This foundational design will guide the policy system's evolution as it grows to meet real-world needs.
