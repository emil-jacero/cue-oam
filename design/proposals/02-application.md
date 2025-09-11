# CUE-OAM Design Document: Application Definition Architecture

2025-09-10

**Status:** Draft  
**Lifecycle:** Proposed  
**Authors:** <emil@jacero.se>  
**Tracking Issue:** emil-jacero/cue-oam#[TBD]  
**Related Roadmap Items:** Core Architecture, Component Model, Application Orchestration  
**Reviewers:** [TBD]  
**Discussion:** GitHub Issue/PR #[TBD]  

## Objective

Establish a comprehensive Application definition architecture that orchestrates components and scopes into cohesive, deployable units. This design provides hierarchical metadata management, dependency resolution, and lifecycle coordination while maintaining the trait-based philosophy of CUE-OAM.

## Background

### Current State

CUE-OAM currently has a basic Application definition that:

- Groups components and scopes together
- Provides basic metadata (name, namespace, version, labels, annotations)
- Allows components and scopes to be defined with unique identifiers

However, the current implementation lacks:

- Application-level traits and behaviors
- Dependency management between components
- Lifecycle orchestration capabilities
- Application-wide policies and constraints
- Multi-environment support
- Versioning and rollback strategies

### Problem Statement

The current Application definition faces several limitations:

1. **No Application-Level Behaviors**: Cannot define traits that affect the entire application
2. **Missing Dependency Management**: No way to express relationships between components
3. **Limited Lifecycle Control**: No orchestration of component deployment order
4. **No Environment Support**: Cannot easily define variations for different environments
5. **Weak Policy Enforcement**: No application-wide constraints or governance

### Goals

- [ ] **Application-Level Traits**: Enable traits that apply to entire applications
- [ ] **Dependency Graph**: Express and validate component dependencies
- [ ] **Lifecycle Management**: Control deployment, updates, and rollbacks
- [ ] **Environment Support**: Define environment-specific configurations
- [ ] **Policy Integration**: Apply application-wide policies and constraints
- [ ] **Bundle Preparation**: Prepare for future Bundle system integration

### Non-Goals

- Implementation of specific providers (separate effort)
- Runtime dependency resolution (design-time only)
- Dynamic application composition
- Cross-application dependencies (reserved for Bundle)
- Application-level service mesh configuration (handled by Scopes)

## Proposal

### Enhanced Application Definition

```cue
#Application: {
    #apiVersion: "core.oam.dev/v2alpha2"
    #kind:       "Application"
    
    // Core metadata
    #metadata: {
        name:         #NameType
        namespace?:   #NameType | *"default"
        version:      #VersionType | *"1.0.0"
        description?: string
        labels?:      #LabelsType
        annotations?: #AnnotationsType
        
        // Application-specific metadata
        maintainers?: [...{
            name:  string
            email: string
            role?: "owner" | "developer" | "operator"
        }]
        
        repository?: {
            url:    string
            branch: string | *"main"
            path?:  string
        }
        
        documentation?: {
            url?:        string
            readme?:     string
            runbook?:    string
            sla?:        string
        }
    }
    
    // Application-level traits
    #traits?: {
        [traitName=string]: #Trait & {
            #metadata: #traits: (traitName): {
                scope: [...("application" | "all-components" | "all-scopes")]
                ...
            }
        }
    }
    
    // Components with enhanced metadata
    components: [Id=string]: #Component & {
        #metadata: {
            #id: Id
            // Inherit application metadata
            labels:      #metadata.labels & {...}
            annotations: #metadata.annotations & {...}
            
            // Component-specific additions
            dependencies?: [...string]  // References to other component IDs
            replicas?: {
                min?: int | *1
                max?: int | *10
                default?: int | *1
            }
            
            // Lifecycle hooks
            lifecycle?: {
                preStart?:  #LifecycleHook
                postStart?: #LifecycleHook
                preStop?:   #LifecycleHook
                postStop?:  #LifecycleHook
            }
        }
    }
    
    // Scopes with application context
    scopes?: [Id=string]: #Scope & {
        #metadata: {
            #id: Id
            // Inherit application metadata
            labels:      #metadata.labels & {...}
            annotations: #metadata.annotations & {...}
            
            // Scope application
            appliesTo?: [...#Component] | "*"  // Component references or "*" for all
        }
    }
    
    // Application-wide policies
    policies?: {
        [policyName=string]: #Policy & {
            #metadata: {
                name: policyName
                type: "security" | "resource" | "compliance" | "operational"
                enforcement: "strict" | "warn" | "audit"
            }
        }
    }
    
    // Environment configurations
    environments?: {
        [envName=string]: #Environment & {
            name: envName
            type: "development" | "staging" | "production" | "custom"
            
            // Environment-specific overrides
            overrides?: {
                components?: {
                    [Id=string]: {
                        // Partial component overrides
                        ...
                    }
                }
                scopes?: {
                    [Id=string]: {
                        // Partial scope overrides
                        ...
                    }
                }
            }
            
            // Environment-specific metadata
            metadata?: {
                labels?:      #LabelsType
                annotations?: #AnnotationsType
            }
        }
    }
    
    // Dependency validation
    _validateDependencies: {
        for compId, comp in components {
            if comp.#metadata.dependencies != _|_ {
                for dep in comp.#metadata.dependencies {
                    // Ensure dependency exists
                    components: (dep): _
                    
                    // Prevent circular dependencies
                    if components[dep].#metadata.dependencies != _|_ {
                        let noDirect = !list.Contains(components[dep].#metadata.dependencies, compId)
                        noDirect | error("Circular dependency detected: \(compId) <-> \(dep)")
                    }
                }
            }
        }
    }
    
    // Application status (computed)
    #status?: {
        componentCount: len(components)
        scopeCount:     len(scopes)
        
        // Deployment readiness
        ready: bool | *true
        
        // Validation results
        validation?: {
            dependencies: "valid" | "invalid"
            policies:     "compliant" | "non-compliant"
            resources:    "within-limits" | "exceeds-limits"
        }
    }
}
```

### Application-Level Traits

Applications can have their own traits that affect the entire application:

```cue
#ApplicationScaling: #Trait & {
    #metadata: #traits: ApplicationScaling: {
        type:   "composite"
        domain: "operational"
        scope:  ["application"]
        provides: scaling: #ApplicationScaling.scaling
    }
    
    scaling: {
        strategy: "horizontal" | "vertical" | "both"
        
        horizontal?: {
            minReplicas: int | *1
            maxReplicas: int | *10
            targetCPUUtilization?: int | *80
        }
        
        vertical?: {
            minResources?: #ResourceRequirements
            maxResources?: #ResourceRequirements
        }
        
        // Apply to all components
        propagate: bool | *true
    }
}

#ApplicationMonitoring: #Trait & {
    #metadata: #traits: ApplicationMonitoring: {
        type:   "composite"
        domain: "observability"
        scope:  ["application"]
        provides: monitoring: #ApplicationMonitoring.monitoring
    }
    
    monitoring: {
        metrics: {
            enabled:  bool | *true
            interval: string | *"30s"
            retention: string | *"30d"
        }
        
        logging: {
            enabled: bool | *true
            level:   "debug" | "info" | "warn" | "error" | *"info"
            format:  "json" | "text" | *"json"
        }
        
        tracing: {
            enabled:  bool | *false
            sampling: float | *0.1
        }
        
        dashboards?: [...{
            name: string
            type: "grafana" | "datadog" | "newrelic"
            config: {...}
        }]
    }
}
```

### Lifecycle Hooks

Support for component lifecycle management:

```cue
#LifecycleHook: {
    exec?: {
        command: [...string]
        env?: [...{name: string, value: string}]
        workingDir?: string
    }
    
    httpGet?: {
        path:   string
        port:   int | string
        host?:  string
        scheme: "HTTP" | "HTTPS" | *"HTTP"
        httpHeaders?: [...{name: string, value: string}]
    }
    
    tcpSocket?: {
        port: int | string
        host?: string
    }
    
    // Timing configuration
    initialDelaySeconds?: int | *0
    timeoutSeconds?:      int | *30
    periodSeconds?:       int | *10
    successThreshold?:    int | *1
    failureThreshold?:    int | *3
}
```

### Dependency Management

Components can declare dependencies for orchestrated deployment:

```cue
// Example usage
myApp: #Application & {
    components: {
        database: {
            #Database
            // No dependencies - deploys first
        }
        
        cache: {
            #Redis
            // No dependencies - deploys in parallel with database
        }
        
        api: {
            #metadata: dependencies: ["database", "cache"]
            #WebService
            // Deploys after database and cache are ready
        }
        
        frontend: {
            #metadata: dependencies: ["api"]
            #WebUI
            // Deploys after API is ready
        }
    }
}
```

### Environment Support

Applications can define environment-specific configurations:

```cue
myApp: #Application & {
    #metadata: {
        name: "ecommerce"
        version: "2.0.0"
    }
    
    components: {
        api: {
            #WebService
            replicas: 2  // Default for all environments
        }
    }
    
    environments: {
        development: {
            type: "development"
            overrides: {
                components: api: {
                    replicas: 1  // Override for development
                    resources: {
                        limits: {cpu: "500m", memory: "512Mi"}
                    }
                }
            }
        }
        
        production: {
            type: "production"
            overrides: {
                components: api: {
                    replicas: 5  // Override for production
                    resources: {
                        limits: {cpu: "2000m", memory: "4Gi"}
                    }
                }
            }
            metadata: {
                labels: {
                    "compliance/pci": "true"
                    "tier": "critical"
                }
            }
        }
    }
}
```

### Policy Integration

Applications can define and enforce policies:

```cue
#ResourcePolicy: #Policy & {
    #metadata: {
        type: "resource"
        enforcement: "strict"
    }
    
    rules: {
        maxMemoryPerContainer: "4Gi"
        maxCPUPerContainer:    "2000m"
        maxStoragePerVolume:   "100Gi"
        
        quotas: {
            totalMemory: "32Gi"
            totalCPU:    "16000m"
            totalStorage: "1Ti"
        }
    }
    
    // Validation logic
    validate: {
        input: #Application
        output: {
            compliant: bool
            violations: [...string]
        }
    }
}

#SecurityPolicy: #Policy & {
    #metadata: {
        type: "security"
        enforcement: "strict"
    }
    
    rules: {
        requireNonRoot:        bool | *true
        requireReadOnlyRoot:   bool | *true
        allowPrivilegeEscalation: bool | *false
        
        requiredSecurityContext: {
            runAsNonRoot: true
            fsGroup:      int | *65534
            seccompProfile: {
                type: "RuntimeDefault"
            }
        }
        
        allowedCapabilities: [...string] | *[]
        forbiddenSysctls:   [...string] | *["*"]
    }
}
```

### Validation Features

The enhanced Application definition includes built-in validations:

1. **Dependency Validation**:
   - Ensures referenced components exist
   - Detects circular dependencies
   - Validates dependency ordering

2. **Resource Validation**:
   - Aggregates resource requirements
   - Validates against policy limits
   - Checks for resource conflicts

3. **Metadata Consistency**:
   - Ensures consistent labeling
   - Validates required annotations
   - Checks naming conventions

4. **Policy Compliance**:
   - Validates against defined policies
   - Reports compliance status
   - Provides violation details

### Provider Integration

Providers will need to support the enhanced Application features:

```cue
#ProviderApplicationSupport: {
    // Required capabilities
    capabilities: {
        metadata:      "full"    // Support hierarchical metadata
        dependencies:  "basic"   // Support dependency ordering
        environments:  "overlay" // Support environment overrides
        policies:      "enforce" // Support policy enforcement
        lifecycle:     "hooks"   // Support lifecycle hooks
    }
    
    // Rendering logic
    render: {
        app: #Application
        environment?: string  // Selected environment
        
        output: {
            // Provider-specific output
            ...
        }
    }
}
```

## Benefits

1. **Complete Application Modeling**: Full representation of application architecture
2. **Dependency Management**: Explicit component relationships and ordering
3. **Environment Flexibility**: Easy management of multi-environment deployments
4. **Policy Enforcement**: Application-wide governance and compliance
5. **Lifecycle Control**: Orchestrated deployment and updates
6. **Better Organization**: Clear structure for complex applications
7. **Metadata Inheritance**: Consistent labeling and annotation
8. **Validation**: Built-in dependency and policy validation

## Testing

1. **Dependency Resolution**: Test valid and circular dependency scenarios
2. **Environment Overrides**: Verify environment-specific configurations
3. **Policy Enforcement**: Test policy validation and compliance
4. **Metadata Inheritance**: Verify hierarchical metadata propagation
5. **Lifecycle Hooks**: Test component lifecycle management
6. **Application Traits**: Verify application-level trait application

## Alternatives Considered

### Flat Component List

Keeping components as a simple list without dependencies was considered but rejected as it doesn't provide enough orchestration control.

### External Dependency Management

Having dependencies managed outside the Application definition was considered but would complicate the model and reduce portability.

### Static Environments

Hard-coding environment types was considered but the flexible approach allows for custom environments while providing standard types.

## Open Questions

1. Should we support cross-application dependencies (reserved for Bundle)?
2. How should we handle component versioning within an application?
3. Should application traits automatically propagate to all components?
4. How do we handle conflicting policies between application and component levels?
5. Should we support conditional component inclusion based on environment?
6. How should rollback strategies be defined and implemented?
7. Should we support progressive deployment strategies (canary, blue-green)?

## Migration Path

For existing CUE-OAM applications:

1. **Phase 1**: Current applications continue to work (backward compatible)
2. **Phase 2**: Add optional enhanced features (dependencies, environments)
3. **Phase 3**: Gradual adoption of new capabilities
4. **Phase 4**: Full migration to enhanced Application definition

## Conclusion

The enhanced Application definition provides a comprehensive framework for orchestrating components and scopes into cohesive, deployable units. By adding support for dependencies, environments, policies, and application-level traits, we enable sophisticated application modeling while maintaining the simplicity and composability that defines CUE-OAM. This design prepares the foundation for future Bundle system integration while solving immediate application orchestration needs.
