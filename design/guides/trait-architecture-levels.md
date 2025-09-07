# Trait Architecture Levels Guide

*Guide for determining which architecture levels make sense for different trait categories*

Date: 2025-01-06  
Subject: Architecture level assignment for traits in the unified trait system

## Overview

This guide helps determine which `#ArchitectureLevel` values to assign to traits based on their category and purpose. The key principle is to think about **what the trait controls** and **where that control makes sense** in your architecture hierarchy.

## Architecture Levels

```cue
#ArchitectureLevel: "component" | "application" | "scope" | "bundle" | "promise"
```

**Hierarchy** (bottom to top):

- **Component**: Where actual work happens
- **Application**: Where services coordinate  
- **Scope**: Where environments are managed
- **Bundle**: Where distributions are controlled
- **Promise**: Where templates/contracts are defined

## Trait Categories with Examples

### Operational Traits (Runtime Behavior)

**Principle**: These control how things execute - they make sense where execution happens.

```cue
#Workload: #Trait & {
    #metadata: #traits: Workload: {
        category: "operational"
        level: ["component"]  // Only components actually run
    }
}

#Scaling: #Trait & {
    #metadata: #traits: Scaling: {
        category: "operational"
        level: ["component", "application"]  // Scale individual components or entire apps
    }
}

#CronJob: #Trait & {
    #metadata: #traits: CronJob: {
        category: "operational"
        level: ["component"]  // Only components can be scheduled
    }
}

#LoadBalancer: #Trait & {
    #metadata: #traits: LoadBalancer: {
        category: "operational"
        level: ["application", "scope"]  // Balance across app or scope
    }
}

#HealthCheck: #Trait & {
    #metadata: #traits: HealthCheck: {
        category: "operational"
        level: ["component"]  // Individual components are health-checked
    }
}

#Lifecycle: #Trait & {
    #metadata: #traits: Lifecycle: {
        category: "operational"
        level: ["component", "application"]  // Startup/shutdown hooks
    }
}
```

### Structural Traits (Organization & Relationships)

**Principle**: These control how things are organized - they work at levels where organization matters.

```cue
#ServiceMesh: #Trait & {
    #metadata: #traits: ServiceMesh: {
        category: "structural"
        level: ["scope", "application"]  // Meshes span multiple components
    }
}

#Namespace: #Trait & {
    #metadata: #traits: Namespace: {
        category: "structural"
        level: ["scope"]  // Namespaces define scope boundaries
    }
}

#Dependency: #Trait & {
    #metadata: #traits: Dependency: {
        category: "structural"
        level: ["component", "application"]  // Components depend on each other
    }
}

#Bundle: #Trait & {
    #metadata: #traits: Bundle: {
        category: "structural"
        level: ["bundle"]  // Bundles are specifically for bundling
    }
}

#ServiceDiscovery: #Trait & {
    #metadata: #traits: ServiceDiscovery: {
        category: "structural"
        level: ["application", "scope"]  // Services discover within apps/scopes
    }
}

#NetworkPolicy: #Trait & {
    #metadata: #traits: NetworkPolicy: {
        category: "structural"
        level: ["scope", "application"]  // Network boundaries
    }
}

#Topology: #Trait & {
    #metadata: #traits: Topology: {
        category: "structural"
        level: ["application", "scope"]  // How components are arranged
    }
}
```

### Behavioral Traits (Logic & Patterns)

**Principle**: These control how things react - they work where reactive behavior is needed.

```cue
#CircuitBreaker: #Trait & {
    #metadata: #traits: CircuitBreaker: {
        category: "behavioral"
        level: ["component", "application"]  // Protect individual services or entire apps
    }
}

#RateLimiter: #Trait & {
    #metadata: #traits: RateLimiter: {
        category: "behavioral"
        level: ["component", "application", "scope"]  // Limit at any level
    }
}

#Retry: #Trait & {
    #metadata: #traits: Retry: {
        category: "behavioral"
        level: ["component"]  // Individual components retry
    }
}

#Backup: #Trait & {
    #metadata: #traits: Backup: {
        category: "behavioral"
        level: ["component", "application", "scope"]  // Backup individual or groups
    }
}

#Throttle: #Trait & {
    #metadata: #traits: Throttle: {
        category: "behavioral"
        level: ["component", "application"]  // Control request rates
    }
}

#Timeout: #Trait & {
    #metadata: #traits: Timeout: {
        category: "behavioral"
        level: ["component"]  // Individual component timeouts
    }
}

#Strategy: #Trait & {
    #metadata: #traits: Strategy: {
        category: "behavioral"
        level: ["component", "application"]  // Deployment/rollback strategies
    }
}
```

### Resource Traits (State & Data)

**Principle**: These control what things have/need - they work where resources are managed.

```cue
#Volume: #Trait & {
    #metadata: #traits: Volume: {
        category: "resource"
        level: ["component"]  // Individual components need storage
    }
}

#Database: #Trait & {
    #metadata: #traits: Database: {
        category: "resource"
        level: ["component"]  // Databases are components
    }
}

#ResourceQuota: #Trait & {
    #metadata: #traits: ResourceQuota: {
        category: "resource"
        level: ["component", "application", "scope", "promise"]  // Quotas at many levels
    }
}

#Config: #Trait & {
    #metadata: #traits: Config: {
        category: "resource"
        level: ["component", "application"]  // Components need config, apps can share config
    }
}

#Secret: #Trait & {
    #metadata: #traits: Secret: {
        category: "resource"
        level: ["component", "application", "scope"]  // Secrets at multiple levels
    }
}

#Cache: #Trait & {
    #metadata: #traits: Cache: {
        category: "resource"
        level: ["component", "application"]  // Local or shared cache
    }
}

#Memory: #Trait & {
    #metadata: #traits: Memory: {
        category: "resource"
        level: ["component"]  // Individual component memory
    }
}

#CPU: #Trait & {
    #metadata: #traits: CPU: {
        category: "resource"
        level: ["component"]  // Individual component CPU
    }
}
```

### Contractual Traits (Constraints & Policies)

**Principle**: These control what must be guaranteed - they work where governance is applied.

```cue
#SecurityPolicy: #Trait & {
    #metadata: #traits: SecurityPolicy: {
        category: "contractual"
        level: ["scope", "application", "component"]  // Security at multiple levels
    }
}

#SLA: #Trait & {
    #metadata: #traits: SLA: {
        category: "contractual"
        level: ["promise", "application", "component"]  // Promises make SLAs
    }
}

#CompliancePolicy: #Trait & {
    #metadata: #traits: CompliancePolicy: {
        category: "contractual"
        level: ["scope", "bundle"]  // Compliance for environments/distributions
    }
}

#Validation: #Trait & {
    #metadata: #traits: Validation: {
        category: "contractual"
        level: ["component", "application"]  // Validate inputs/outputs
    }
}

#AccessControl: #Trait & {
    #metadata: #traits: AccessControl: {
        category: "contractual"
        level: ["scope", "application", "component"]  // Who can access what
    }
}

#Encryption: #Trait & {
    #metadata: #traits: Encryption: {
        category: "contractual"
        level: ["component", "application", "scope"]  // Data protection
    }
}

#Audit: #Trait & {
    #metadata: #traits: Audit: {
        category: "contractual"
        level: ["scope", "application", "component"]  // Audit logging
    }
}

#Schema: #Trait & {
    #metadata: #traits: Schema: {
        category: "contractual"
        level: ["component", "application"]  // Data validation schemas
    }
}
```

## Decision Rules by Level

### Component Level

**When to use**: Where actual work happens

**Categories that often apply here**:

- **Operational**: Workload, Task, CronJob, HealthCheck
- **Resource**: Volume, Database, Config, Memory, CPU
- **Behavioral**: Retry, Timeout
- **Contractual**: Validation, Schema

**Rule**: If the trait controls something that individual components do or need.

### Application Level

**When to use**: Where services coordinate

**Categories that often apply here**:

- **Structural**: ServiceDiscovery, LoadBalancer, NetworkPolicy
- **Behavioral**: CircuitBreaker, RateLimiter (app-wide)
- **Resource**: SharedConfig, ApplicationCache
- **Contractual**: ApplicationSLA, ValidationRules

**Rule**: If the trait manages relationships or shared concerns between components.

### Scope Level

**When to use**: Where environments are managed

**Categories that often apply here**:

- **Structural**: Namespace, NetworkPolicy, ServiceMesh
- **Resource**: ResourceQuota, EnvironmentConfig
- **Contractual**: SecurityPolicy, ComplianceRules
- **Operational**: LoadBalancer (environment-wide)

**Rule**: If the trait applies to all components within an environment/namespace.

### Bundle Level

**When to use**: Where distributions are controlled

**Categories that often apply here**:

- **Structural**: BundleManifest, Dependencies
- **Contractual**: VersionPolicy, DistributionRules
- **Resource**: BundleResources (rare)

**Rule**: If the trait controls how components are packaged and distributed together.

### Promise Level

**When to use**: Where templates/contracts are defined

**Categories that often apply here**:

- **Contractual**: SLA, UsagePolicy, TemplateValidation
- **Resource**: DefaultResourceLimits
- **Structural**: TemplateStructure (rare)

**Rule**: If the trait defines defaults or constraints for everything created from the promise.

## Common Level Patterns

### Single Level (Very Specific Purpose)

```cue
#Workload: level: ["component"]  // Only components run
#Namespace: level: ["scope"]     // Only scopes have namespaces
#Bundle: level: ["bundle"]       // Only bundles are bundled
```

### Two Levels (Specific but Flexible)

```cue
#Database: level: ["component"]                    // Databases are components
#ServiceMesh: level: ["scope", "application"]      // Meshes span groups
#CircuitBreaker: level: ["component", "application"] // Protection at 2 levels
```

### Multiple Levels (Cross-cutting Concerns)

```cue
#ResourceQuota: level: ["component", "application", "scope", "promise"]
#SecurityPolicy: level: ["scope", "application", "component"]
#RateLimiter: level: ["component", "application", "scope"]
```

### Rare: All Levels (Only for Very Generic Traits)

```cue
#Labels: level: ["promise", "bundle", "scope", "application", "component"]
#Metadata: level: ["promise", "bundle", "scope", "application", "component"]
```

## Decision Process

When assigning levels to a trait, ask these questions:

1. **What does this trait control?** (runtime, organization, logic, resources, constraints)
2. **Where in the hierarchy does that control make sense?**
3. **What would break if this trait was applied at the wrong level?**
4. **What value does applying this trait at each level provide?**

### Example: CircuitBreaker

1. **What does it control?** Failure handling logic
2. **Where does it make sense?**
   - Component: Protect individual service calls
   - Application: Protect entire application from cascading failures
   - Scope: Probably too broad - circuit breakers need to be specific
3. **What would break?**
   - At Promise/Bundle: Too abstract, no actual calls to protect
   - At Scope: Too broad, would affect unrelated components
4. **Value at each level?**
   - Component: High - protect specific service interactions
   - Application: High - protect app-wide failure scenarios

**Result**: `level: ["component", "application"]`

## Anti-Patterns to Avoid

### Too Broad

```cue
// Bad: Workload at scope level doesn't make sense
#Workload: level: ["scope", "application", "component"]

// Good: Workloads only exist at component level
#Workload: level: ["component"]
```

### Too Narrow

```cue
// Bad: ResourceQuota only at component misses organizational needs
#ResourceQuota: level: ["component"]

// Good: ResourceQuota works at multiple organizational levels
#ResourceQuota: level: ["component", "application", "scope", "promise"]
```

### Category Mismatch

```cue
// Bad: Structural trait only at component level
#ServiceMesh: level: ["component"]  // Meshes connect multiple components!

// Good: Structural traits usually work at higher levels
#ServiceMesh: level: ["scope", "application"]
```

## Validation Rules

When defining trait levels, ensure:

1. **Operational traits** usually include `"component"` (where execution happens)
2. **Structural traits** usually include `"application"` or `"scope"` (where organization happens)
3. **Contractual traits** often span multiple levels (policies apply broadly)
4. **Resource traits** start at `"component"` but may scale up
5. **Behavioral traits** apply where the behavior makes sense

Remember: **The key is asking "Where does this trait's concern naturally apply in the architecture?"**
