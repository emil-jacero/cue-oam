# CUE-OAM Design Document: Scope System for Cross-Cutting Concerns

2025-09-07

**Status:** Draft  
**Lifecycle:** Incoherent Rambling  
**Authors:** <emil@jacero.se>  
**Tracking Issue:** emil-jacero/cue-oam#[TBD]  
**Related Roadmap Items:** Core Architecture, Scope System, Trait Composition  
**Reviewers:** [TBD]  
**Discussion:** GitHub Issue/PR #[TBD]  

## Objective

Establish a scope system that unifies Components and Scopes under a common trait-based architecture. Both Components and Scopes are trait compositions, with Scopes serving as additions to Components that manage cross-cutting concerns at Application and Bundle levels.

## Background

### Current State

The unified trait architecture provides a foundation where both Components and Scopes are trait compositions:

- Components compose traits to define workload behavior
- Scopes compose traits to define cross-cutting concerns that affect components
- Both inherit from #Trait, providing a unified architecture
- Applications contain components with scopes as additions that apply policies and cross-cutting concerns
- Scopes reference components via an `affects` field to specify which components they apply to
- Scopes are inherently a `Modifier` trait

### Problem Statement

Modern applications require managing operational concerns that span multiple components:

1. **Network Policies**: Service mesh, ingress/egress rules, DNS configuration
2. **Security Boundaries**: RBAC, compliance frameworks, isolation policies  
3. **Resource Management**: Quotas, limits, affinity rules across component groups
4. **Deployment Coordination**: Rollout strategies, health checks, dependencies

Example scenario requiring scopes:

```cue
// Components defined separately
frontend: #WebService & {...}
backend: #WebService & {...}
database: #Database & {...}

// Application brings components together and adds scopes
myApp: #Application & {
    components: {
        frontend: frontend
        backend: backend
        database: database
    }
    
    // Scopes are additions that manage cross-cutting concerns
    scopes: {
        webTier: #NetworkScope & {
            // References components by their keys
            affects: ["frontend", "backend"]
            network: {
                isolation: "namespace"
                serviceMesh: enabled: true
            }
        }
        
        dataLayer: #SecurityScope & {
            affects: ["database"]
            security: {
                rbac: enabled: true
                compliance: frameworks: ["SOC2"]
            }
        }
    }
}
```

### Goals

- [x] **Unified Architecture**: Components and Scopes both inherit from #Trait
- [x] **Trait Composition**: Scopes compose traits just like Components
- [x] **Application Integration**: Applications contain components with scopes as additions
- [x] **Explicit Relationships**: Scopes explicitly declare which components they affect
- [ ] **Cross-Cutting Management**: Scopes manage concerns that span multiple components
- [ ] **Provider Translation**: Enable platform-specific scope implementations

### Non-Goals

- Runtime scope modification (design-time composition only)
- Automatic component-to-scope discovery (explicit assignment required)
- Cross-bundle scoping (maintain clear boundaries)

## Proposal

### CUE-OAM Model Impact

The unified architecture where both Components and Scopes inherit from #Trait:

- **Common Base**: Both #Component and #Scope are composed from #Trait
- **Trait Metadata**: Components and Scopes have #metadata with #traits field
- **Application Structure**: Applications contain components as primary workloads, with scopes as additions that apply cross-cutting concerns
- **Scope-Component Relationship**: Scopes use an `affects` field to specify which components they apply to
- **Trait Scope Field**: The `scope` field in #TraitMeta determines where traits can be applied
- **Provider Requirements**: Providers process components first, then apply scope effects to affected components

### Unified Architecture

Both Components and Scopes inherit from #Trait, creating a unified system where Components define workloads and Scopes add cross-cutting concerns:

```cue
// Base trait definition (from trait.cue)
#Trait: {
    #metadata: {
        #traits: [traitName=string]: #TraitMeta & {
            name: traitName
        }
    }
    // Trait-specific fields
    ...
}

// Component definition (from component.cue)
#Component: {
    #apiVersion: "core.oam.dev/v2alpha1"
    #kind:       "Component"
    #metadata: {
        labels?:      #LabelsType
        annotations?: #AnnotationsType
    }
    #Trait  // Inherits from #Trait
}

// Scope definition (from scope.cue)
#Scope: {
    #apiVersion: "core.oam.dev/v2alpha1"
    #kind:       "Scope"
    #metadata: #ScopeMeta & {
        labels?:      #LabelsType
        annotations?: #AnnotationsType
    }
    #Trait  // Inherits from #Trait
    
    // Specifies which components this scope affects
    affects: [...string]
}
```

### Component Traits vs Scope Traits

The key distinction is in the `scope` field:

```cue
// A trait that can be used in Components
#Workload: #Trait & {
    #metadata: #traits: Workload: #TraitMeta & {
        name: "Workload"
        scope: ["component"]  // Only for components
        domain: "operational"
        provides: workload: {...}
    }
    workload: {...}
}

// A trait that can be used in Scopes
#NetworkPolicy: #Trait & {
    #metadata: #traits: NetworkPolicy: #TraitMeta & {
        name: "NetworkPolicy"
        scope: ["scope"]  // Only for scopes
        domain: "structural"
        provides: policy: {...}
    }
    policy: {...}
}

// A trait that can be used in both
#Monitoring: #Trait & {
    #metadata: #traits: Monitoring: #TraitMeta & {
        name: "Monitoring"
        scope: ["component", "scope"]  // Both
        domain: "operational"
        provides: monitoring: {...}
    }
    monitoring: {...}
}
```

### Application Integration

Applications contain components with scopes as additional cross-cutting concerns:

```cue
#Application: {
    #apiVersion: "core.oam.dev/v2alpha1"
    #kind:       "Application"
    #metadata: {
        name:         #NameType
        namespace?:   #NameType
        labels?:      #LabelsType
        annotations?: #AnnotationsType
    }
    components: [string]: #Component
    scopes: [string]:     #Scope
}
```

### User Experience Examples

#### Basic Application with Components and Scopes

```cue
myApp: #Application & {
    #metadata: {
        name: "web-application"
        namespace: "production"
    }
    
    // Components define the workloads
    components: {
        frontend: #Component & {
            #metadata: {
                #id: "frontend"
                name: "frontend-service"
                #traits: {
                    Workload: {
                        name: "Workload"
                        scope: ["component"]
                        domain: "operational"
                        provides: workload: {...}
                    }
                    Expose: {
                        name: "Expose"
                        scope: ["component"]
                        domain: "structural"
                        provides: expose: port: 3000
                    }
                }
            }
            workload: containers: main: image: "frontend:v1.0"
            expose: port: 3000
        }
        
        backend: #Component & {
            #metadata: {
                #id: "backend"
                name: "backend-service"
                #traits: {
                    Workload: {...}
                    Expose: {
                        provides: expose: port: 8080
                    }
                }
            }
            workload: containers: main: image: "backend:v1.0"
            expose: port: 8080
        }
        
        database: #Component & {
            #metadata: {
                #id: "database"
                name: "postgres-db"
                #traits: {
                    Database: {
                        name: "Database"
                        scope: ["component"]
                        domain: "resource"
                        provides: database: {...}
                    }
                }
            }
            database: {
                type: "postgres"
                version: "14"
            }
        }
    }
    
    // Scopes are additions that apply cross-cutting concerns to components
    scopes: {
        network: #Scope & {
            #metadata: {
                #id: "network"
                name: "app-network"
                #traits: {
                    NetworkPolicy: {
                        name: "NetworkPolicy"
                        scope: ["scope"]
                        domain: "structural"
                        provides: policy: {...}
                    }
                    ServiceMesh: {
                        name: "ServiceMesh"
                        scope: ["scope"]
                        domain: "structural"
                        provides: mesh: {...}
                    }
                }
            }
            // Specifies which components this scope affects
            affects: ["frontend", "backend"]
            
            policy: {
                isolation: "namespace"
                ingress: [{
                    from: [{namespaceSelector: {}}]
                    ports: [{protocol: "TCP", port: 80}]
                }]
            }
            mesh: {
                enabled: true
                mTLS: true
            }
        }
        
        security: #Scope & {
            #metadata: {
                #id: "security"
                name: "app-security"
                #traits: {
                    RBAC: {
                        name: "RBAC"
                        scope: ["scope"]
                        domain: "contractual"
                        provides: rbac: {...}
                    }
                    Compliance: {
                        name: "Compliance"
                        scope: ["scope"]
                        domain: "contractual"
                        provides: compliance: {...}
                    }
                }
            }
            // This scope affects only the database component
            affects: ["database"]
            
            rbac: {
                enabled: true
                rules: [{
                    apiGroups: [""]
                    resources: ["secrets"]
                    verbs: ["get", "list"]
                }]
            }
            compliance: {
                frameworks: ["SOC2"]
            }
        }
        
        resources: #Scope & {
            #metadata: {
                #id: "resources"
                name: "resource-limits"
                #traits: {
                    ResourceQuota: {
                        name: "ResourceQuota"
                        scope: ["scope"]
                        domain: "resource"
                        provides: quota: {...}
                    }
                }
            }
            // This scope affects all components in the application
            affects: ["frontend", "backend", "database"]
            
            quota: {
                cpu: "2000m"
                memory: "4Gi"
            }
        }
    }
}
```

## Benefits

1. **Unified Architecture**: Components and Scopes both inherit from #Trait, providing consistency
2. **Clear Separation**: Components handle workload concerns, Scopes add cross-cutting concerns
3. **Explicit Relationships**: The `affects` field clearly shows which components a scope applies to
4. **Type Safety**: The `scope` field ensures traits are only used in appropriate contexts
5. **Composability**: Both Components and Scopes support atomic and composite trait patterns
6. **Provider Clarity**: Clear semantics for how scopes augment component behavior

## Implementation Plan

### Foundation

- [x] Establish unified #Trait base for Components and Scopes
- [x] Define `scope` field in #TraitMeta
- [x] Implement #Component and #Scope as #Trait extensions
- [ ] Create core scope-specific traits (NetworkPolicy, RBAC, ResourceQuota)
- [ ] Add trait context validation

## Alternatives Considered

### Separate Type Systems

**Alternative**: Keep Components and Scopes as completely separate types
**Rejected**: Would duplicate trait system logic and reduce consistency

### Application-Level Traits

**Alternative**: Allow traits directly on Applications without Scopes
**Rejected**: Applications should orchestrate, not implement concerns directly

### Mixed Trait Usage

**Alternative**: Allow any trait to be used anywhere without restrictions
**Rejected**: Would lose semantic clarity about trait purposes and contexts

## Conclusion

The unified architecture where both Components and Scopes inherit from #Trait creates a consistent, powerful system for managing all aspects of applications. Components compose traits for workload-specific behavior, while Scopes serve as additions that compose traits for cross-cutting concerns. The `affects` field in Scopes explicitly declares which components are impacted, creating clear relationships between workloads and their operational policies. The `scope` field in #TraitMeta ensures traits are used in appropriate contexts while allowing flexibility for traits that span multiple contexts. This design maintains architectural clarity, enables sophisticated composition patterns, and provides providers with a clear model for applying scope effects to components.
