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
- Applications contain components with scopes as additions that apply policies and concerns
- Scopes reference components via an `affects` field to specify which components they apply to

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
- [ ] **Bundle Integration**: Support scopes at Bundle level for distribution concerns
- [ ] **Cross-Cutting Management**: Scopes manage concerns that span multiple components
- [ ] **Provider Translation**: Enable platform-specific scope implementations

### Non-Goals

- Runtime scope modification (design-time composition only)
- Automatic component-to-scope discovery (explicit assignment required)
- Cross-bundle scoping (maintain clear boundaries)

## Proposal

### CUE-OAM Model Impact

The unified architecture where both Components and Scopes inherit from #Trait:

- **Common Base**: Both #Component and #Scope extend #Trait
- **Trait Metadata**: Components and Scopes have #metadata with #traits field
- **Application Structure**: Applications contain components as primary workloads, with scopes as additions that apply cross-cutting concerns
- **Scope-Component Relationship**: Scopes use an `affects` field to specify which components they apply to
- **Trait Scope Field**: The `traitScope` field in #TraitObject determines where traits can be applied
- **Provider Requirements**: Providers process components first, then apply scope effects to affected components

### Unified Architecture

Both Components and Scopes inherit from #Trait, creating a unified system where Components define workloads and Scopes add cross-cutting concerns:

```cue
// Base trait definition (from trait.cue)
#Trait: {
    #metadata: #ComponentMeta & {
        #traits: [traitName=string]: #TraitObject & {
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
    #metadata: #ComponentMeta & {
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

// Metadata structures
#ComponentMeta: {
    #id:  #NameType
    name: #NameType | *#id
    ...
}

#ScopeMeta: {
    #id:  #NameType
    name: #NameType | *#id
    ...
}
```

### Trait Scope Field

The `traitScope` field in #TraitObject determines where traits can be applied:

```cue
#TraitScope: "component" | "scope" | "bundle" | "promise"

#TraitObject: {
    name: #NameType
    
    // Where this trait can be applied
    traitScope: [...#TraitScope]
    
    // Category of concern this trait addresses
    category: #TraitCategory
    
    // What this trait provides
    provides: {...}
    
    // Dependencies
    requires?: [...string]
    
    // Composition (for composite traits)
    composes?: [...#TraitObject]
    
    // Attributes
    attributes: [string]: bool
}
```

### Core Scope Types

#### Network Scope

A scope that manages network policies and connectivity:

```cue
#NetworkScope: #Scope & {
    #metadata: #traits: NetworkScope: #TraitObject & {
        name: "NetworkScope"
        traitScope: ["scope"]  // This trait applies to scopes
        category: "structural"
        provides: network: #NetworkScope.network
        requires: [
            "core.oam.dev/v1.NetworkPolicy",
            "core.oam.dev/v1.ServiceMesh"
        ]
        attributes: {
            replicable: false
            daemonized: false
            exposed: true
        }
    }
    
    // Components affected by this scope
    affects: [...string]

    network: {
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
```

#### Security Scope

A scope that manages security policies and RBAC:

```cue
#SecurityScope: #Scope & {
    #metadata: #traits: SecurityScope: #TraitObject & {
        name: "SecurityScope"
        traitScope: ["scope"]
        category: "contractual"
        provides: security: #SecurityScope.security
        requires: [
            "core.oam.dev/v1.RBAC",
            "core.oam.dev/v1.PodSecurityPolicy"
        ]
        attributes: {
            replicable: false
            daemonized: false
            exposed: false
        }
    }
    
    // Components affected by this scope
    affects: [...string]

    security: {
        // Pod security context
        podSecurityContext?: {
            runAsNonRoot?: bool
            runAsUser?: int
            fsGroup?: int
            seccompProfile?: {
                type: "RuntimeDefault" | "Localhost" | "Unconfined"
            }
        }
        
        // RBAC configuration
        rbac?: {
            enabled: bool | *false
            serviceAccount?: string
            rules?: [...{
                apiGroups: [...string]
                resources: [...string]
                verbs: [...string]
            }]
        }
        
        // Compliance frameworks
        compliance?: {
            frameworks?: [...("SOC2" | "PCI-DSS" | "HIPAA" | "GDPR")]
            auditing?: {
                enabled: bool | *false
                retention?: string | *"90d"
            }
        }
    }
}
```

#### Resource Scope

A scope that manages resource allocation and constraints:

```cue
#ResourceScope: #Scope & {
    #metadata: #traits: ResourceScope: #TraitObject & {
        name: "ResourceScope"
        traitScope: ["scope"]
        category: "resource"
        provides: resources: #ResourceScope.resources
        requires: [
            "core.oam.dev/v1.ResourceQuota",
            "core.oam.dev/v1.LimitRange"
        ]
        attributes: {
            replicable: false
            daemonized: false
            exposed: false
        }
    }
    
    // Components affected by this scope
    affects: [...string]

    resources: {
        // Resource quotas
        quota?: {
            cpu?: string
            memory?: string
            storage?: string
            pods?: int
        }
        
        // Default limits applied to components
        limits?: {
            cpu?: string
            memory?: string
        }
        
        // Default requests applied to components
        requests?: {
            cpu?: string
            memory?: string
        }
        
        // Node affinity for all components
        nodeAffinity?: {
            requiredDuringSchedulingIgnoredDuringExecution?: {...}
            preferredDuringSchedulingIgnoredDuringExecution?: [...{...}]
        }
        
        // Priority class
        priorityClass?: string
    }
}
```

### Component Traits vs Scope Traits

The key distinction is in the `traitScope` field:

```cue
// A trait that can be used in Components
#Workload: #Trait & {
    #metadata: #traits: Workload: #TraitObject & {
        name: "Workload"
        traitScope: ["component"]  // Only for components
        category: "operational"
        provides: workload: {...}
    }
    workload: {...}
}

// A trait that can be used in Scopes
#NetworkPolicy: #Trait & {
    #metadata: #traits: NetworkPolicy: #TraitObject & {
        name: "NetworkPolicy"
        traitScope: ["scope"]  // Only for scopes
        category: "structural"
        provides: policy: {...}
    }
    policy: {...}
}

// A trait that can be used in both
#Monitoring: #Trait & {
    #metadata: #traits: Monitoring: #TraitObject & {
        name: "Monitoring"
        traitScope: ["component", "scope"]  // Both
        category: "operational"
        provides: monitoring: {...}
    }
    monitoring: {...}
}
```

### Bundle-Level Scopes

Scopes with `traitScope: ["bundle"]` operate at the Bundle level:

#### Compliance Scope

A scope for regulatory and organizational requirements:

```cue
#ComplianceScope: #Scope & {
    #metadata: #traits: ComplianceScope: #TraitObject & {
        name: "ComplianceScope"
        traitScope: ["bundle"]
        category: "contractual"
        provides: compliance: #ComplianceScope.compliance
        requires: [
            "core.oam.dev/v1.PolicyEngine",
            "core.oam.dev/v1.AuditLog"
        ]
        attributes: {
            replicable: false
            daemonized: false
            exposed: false
        }
    }

    compliance: {
        // Regulatory frameworks
        frameworks: [...("SOX" | "PCI-DSS" | "GDPR" | "HIPAA" | "FedRAMP")]
        
        // Data classification
        dataClassification?: {
            level: "public" | "internal" | "confidential" | "restricted"
            retention?: string
            encryption?: "at-rest" | "in-transit" | "both"
        }
        
        // Audit requirements
        auditing?: {
            enabled: bool | *true
            retention?: string | *"7y"
            realtime?: bool | *false
        }
        
        // Geographic restrictions
        geography?: {
            allowedRegions?: [...string]
            dataResidency?: bool | *false
        }
    }
}
```

### Application Integration

Applications contain components with scopes as additional cross-cutting concerns:

```cue
#Application: {
    #apiVersion: "core.oam.dev/v2alpha1"
    #kind:       "Application"
    #metadata: #ComponentMeta & {
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
                        traitScope: ["component"]
                        category: "operational"
                        provides: workload: {...}
                    }
                    Expose: {
                        name: "Expose"
                        traitScope: ["component"]
                        category: "structural"
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
                        traitScope: ["component"]
                        category: "resource"
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
                        traitScope: ["scope"]
                        category: "structural"
                        provides: policy: {...}
                    }
                    ServiceMesh: {
                        name: "ServiceMesh"
                        traitScope: ["scope"]
                        category: "structural"
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
                        traitScope: ["scope"]
                        category: "contractual"
                        provides: rbac: {...}
                    }
                    Compliance: {
                        name: "Compliance"
                        traitScope: ["scope"]
                        category: "contractual"
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
                        traitScope: ["scope"]
                        category: "resource"
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

#### Composite Traits in Components and Scopes

Both Components and Scopes can use composite traits:

```cue
// Composite trait for Components
#WebService: #Component & {
    #metadata: #traits: {
        WebService: #TraitObject & {
            name: "WebService"
            traitScope: ["component"]
            category: "operational"
            composes: [
                {name: "Workload", ...},
                {name: "Expose", ...},
                {name: "Monitoring", ...}
            ]
            provides: {...}
        }
    }
    // Composed trait fields
    workload: {...}
    expose: {...}
    monitoring: {...}
}

// Composite trait for Scopes
#SecureNetwork: #Scope & {
    #metadata: #traits: {
        SecureNetwork: #TraitObject & {
            name: "SecureNetwork"
            traitScope: ["scope"]
            category: "structural"
            composes: [
                {name: "NetworkPolicy", ...},
                {name: "ServiceMesh", ...},
                {name: "TLS", ...}
            ]
            provides: {...}
        }
    }
    // Composed trait fields
    policy: {...}
    mesh: {...}
    tls: {...}
}
```

#### Bundle with Distribution Scope

```cue
ecommerceBundle: #Bundle & {
    name: "ecommerce-platform"
    version: "2.1.0"
    
    applications: {
        frontend: #FrontendApp
        backend: #BackendApp
        analytics: #AnalyticsApp
    }
    
    scopes: {
        distribution: #DistributionScope & {
            distribution: {
                registry: {
                    url: "registry.company.com/ecommerce"
                    namespace: "production"
                }
                versioning: {
                    scheme: "semver"
                    channels: ["stable", "beta", "alpha"]
                }
                targets: {
                    environments: ["staging", "production"]
                    regions: ["us-east-1", "eu-west-1"]
                }
            }
        }
        
        compliance: #ComplianceScope & {
            compliance: {
                frameworks: ["PCI-DSS", "GDPR"]
                dataClassification: {
                    level: "confidential"
                    encryption: "both"
                }
                geography: {
                    dataResidency: true
                    allowedRegions: ["US", "EU"]
                }
            }
        }
    }
}
```

### Provider Integration

Providers handle both Component and Scope trait compositions:

```cue
// Kubernetes provider handles both types
#KubernetesProvider: {
    // Transform application with components and scopes
    transform: (app: #Application) => {
        // Process components
        for componentKey, component in app.components {
            // Generate resources for component traits
            for traitName, traitMeta in component.#metadata.#traits {
                if "component" in traitMeta.traitScope {
                    // Generate Kubernetes resources for component traits
                    ...
                }
            }
        }
        
        // Process scopes as additions to components
        for scopeKey, scope in app.scopes {
            // Apply scope effects to affected components
            for componentKey in scope.affects {
                component: app.components[componentKey]
                
                // Generate scope resources that affect the component
                for traitName, traitMeta in scope.#metadata.#traits {
                    if "scope" in traitMeta.traitScope {
                        switch traitName {
                            case "NetworkPolicy":
                                // Create NetworkPolicy for this component
                                "networkpolicy-\(componentKey)": {...}
                            case "RBAC":
                                // Create RBAC rules for this component
                                "role-\(componentKey)": {...}
                            case "ResourceQuota":
                                // Apply resource constraints to this component
                                ...
                        }
                    }
                }
            }
        }
    }
}
```

### Trait Discovery and Validation

The system validates trait usage based on `traitScope`:

```cue
// Validation helper
#ValidateTraitUsage: {
    trait: #TraitObject
    context: "component" | "scope" | "bundle" | "promise"
    
    valid: context in trait.traitScope
    
    if !valid {
        error("Trait '\(trait.name)' cannot be used in \(context) context. Valid contexts: \(trait.traitScope)")
    }
}

// Example validation
myComponent: #Component & {
    #metadata: #traits: {
        // Valid: Workload can be used in components
        Workload: #TraitObject & {
            traitScope: ["component"]
            ...
        }
        
        // Invalid: NetworkPolicy can't be used in components
        NetworkPolicy: #TraitObject & {
            traitScope: ["scope"]  // Error: wrong context
            ...
        }
    }
}
```

## Benefits

1. **Unified Architecture**: Components and Scopes both inherit from #Trait, providing consistency
2. **Clear Separation**: Components handle workload concerns, Scopes add cross-cutting concerns
3. **Explicit Relationships**: The `affects` field clearly shows which components a scope applies to
4. **Type Safety**: The `traitScope` field ensures traits are only used in appropriate contexts
5. **Composability**: Both Components and Scopes support atomic and composite trait patterns
6. **Provider Clarity**: Clear semantics for how scopes augment component behavior

## Implementation Plan

### Phase 1: Foundation

- [x] Establish unified #Trait base for Components and Scopes
- [x] Define `traitScope` field in #TraitObject
- [x] Implement #Component and #Scope as #Trait extensions
- [ ] Create core scope-specific traits (NetworkPolicy, RBAC, ResourceQuota)
- [ ] Add trait context validation

### Phase 2: Trait Development

- [ ] Define component-specific traits (Workload, Database, etc.)
- [ ] Define scope-specific traits (NetworkPolicy, ServiceMesh, etc.)
- [ ] Create dual-context traits (Monitoring, Logging, etc.)
- [ ] Implement composite trait patterns for both types

### Phase 3: Application Integration

- [ ] Implement Application structure with components and scopes
- [ ] Add Bundle-level scope support
- [ ] Create trait dependency resolution
- [ ] Implement trait composition validation

### Phase 4: Provider Support

- [ ] Implement unified trait transformation
- [ ] Add Kubernetes provider for both component and scope traits
- [ ] Create Docker Compose provider support
- [ ] Implement trait conflict resolution

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

The unified architecture where both Components and Scopes inherit from #Trait creates a consistent, powerful system for managing all aspects of applications. Components compose traits for workload-specific behavior, while Scopes serve as additions that compose traits for cross-cutting concerns. The `affects` field in Scopes explicitly declares which components are impacted, creating clear relationships between workloads and their operational policies. The `traitScope` field in #TraitObject ensures traits are used in appropriate contexts while allowing flexibility for traits that span multiple contexts. This design maintains architectural clarity, enables sophisticated composition patterns, and provides providers with a clear model for applying scope effects to components.
