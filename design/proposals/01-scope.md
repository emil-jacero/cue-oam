# CUE-OAM Design Document: Scope System for Cross-Cutting Concerns

2025-09-06

**Status:** Draft  
**Lifecycle:** Proposed  
**Authors:** <emil@jacero.se>  
**Tracking Issue:** emil-jacero/cue-oam#[TBD]  
**Related Roadmap Items:** Core Architecture, Scope System, Trait Composition  
**Reviewers:** [TBD]  
**Discussion:** GitHub Issue/PR #[TBD]  

## Objective

Establish a scope system that enables trait-based management of cross-cutting concerns at Application and Bundle levels. Scopes group components and apply shared operational policies like networking, security, resource management, and deployment strategies without requiring traits directly at the Application level.

## Background

### Current State

The unified trait architecture successfully handles concerns at the Component level through atomic and composite traits. However, there's a gap in managing cross-cutting concerns that affect multiple components collectively:

- Components have rich trait composition capabilities
- Applications orchestrate components but lack their own traits
- No mechanism exists for shared policies across component groups
- Bundle-level operational concerns are undefined

### Problem Statement

Modern applications require managing operational concerns that span multiple components:

1. **Network Policies**: Service mesh, ingress/egress rules, DNS configuration
2. **Security Boundaries**: RBAC, compliance frameworks, isolation policies  
3. **Resource Management**: Quotas, limits, affinity rules across component groups
4. **Deployment Coordination**: Rollout strategies, health checks, dependencies

Example scenario requiring scopes:

```cue
// Current: No way to express shared network policy
frontend: #WebService & {...}
backend: #WebService & {...}
database: #Database & {...}

// Desired: Group components with shared networking
myApp: #Application & {
    scopes: {
        webTier: #NetworkScope & {
            components: [frontend, backend]
            isolation: "namespace"
            serviceMesh: enabled: true
        }
    }
}
```

### Goals

- [x] **Trait-Based Scopes**: Integrate scopes with the unified trait system  
- [x] **Application Integration**: Enable scopes at Application level
- [ ] **Bundle Integration**: Support scopes at Bundle level for distribution concerns
- [ ] **Component Grouping**: Explicit assignment of components to scopes
- [ ] **Policy Application**: Apply shared configurations across scope members
- [ ] **Provider Translation**: Enable platform-specific scope implementations

### Non-Goals

- Runtime scope modification (design-time composition only)
- Automatic component-to-scope discovery (explicit assignment required)
- Cross-bundle scoping (maintain clear boundaries)

## Proposal

### CUE-OAM Model Impact

Scopes extend the trait system for cross-cutting concerns:

- **New Scope Traits**: Specialized traits with `scope: ["scope"]` or `scope: ["bundle"]`
- **Application Changes**: Applications contain scopes that reference their components
- **Bundle Changes**: Bundles can define scopes for distribution/deployment concerns
- **Component Changes**: Components remain unchanged (no scope traits applied to them)
- **Provider Requirements**: Providers must handle scope traits and apply them to component groups

### Scope Architecture

Scopes are specialized traits that operate at Application and Bundle levels:

```cue
#ScopeTrait: #Trait & {
    #metadata: #traits: #TraitMeta & {
        scope: ["scope"] | ["bundle"] | ["scope", "bundle"]
    }
    // The components to attach to this scope
    components: [...#Component]
    ...
}

#SecurityScope: #Trait & {
    #metadata: #traits: SecurityScope: {
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

// Scope traits have specific scope values
#ScopeTraitMeta: #TraitMeta & {
    scope: ["scope"] | ["bundle"] | ["scope", "bundle"]
}

// Base pattern for scope implementations
#ApplicationScope: #Trait & {
    #metadata: #traits: [ScopeName=string]: #ScopeTraitMeta & {
        scope: ["scope"]
    }
}

#BundleScope: #Trait & {
    #metadata: #traits: [ScopeName=string]: #ScopeTraitMeta & {
        scope: ["bundle"]
    }
}
```

### Core Scope Types

#### Network Scope

Manages network policies and connectivity for component groups:

```cue
#NetworkScope: #ApplicationScope & {
    #metadata: #traits: NetworkScope: {
        category: "structural"
        provides: network: #NetworkScope.network
        scope: ["scope"]
        requires: [
            "core.oam.dev/v1.NetworkPolicy",
            "core.oam.dev/v1.ServiceMesh"
        ]
    }

    network: {
        // Network isolation level
        isolation: "none" | "namespace" | "pod" | "strict" | *"namespace"
        
        // Component references this scope affects
        components: [...string]
        
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

Manages security policies and RBAC:

```cue
#SecurityScope: #ApplicationScope & {
    #metadata: #traits: SecurityScope: {
        category: "contractual"
        provides: security: #SecurityScope.security
        scope: ["scope"]
        requires: [
            "core.oam.dev/v1.RBAC",
            "core.oam.dev/v1.PodSecurityPolicy"
        ]
    }

    security: {
        // Components affected by this security scope
        components: [...string]
        
        // Pod security context applied to all components
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

Manages resource allocation and constraints:

```cue
#ResourceScope: #ApplicationScope & {
    #metadata: #traits: ResourceScope: {
        category: "resource"
        provides: resources: #ResourceScope.resources
        scope: ["scope"]
        requires: [
            "core.oam.dev/v1.ResourceQuota",
            "core.oam.dev/v1.LimitRange"
        ]
    }

    resources: {
        // Components sharing these resource constraints
        components: [...string]
        
        // Resource quotas for the scope
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

### Bundle-Level Scopes

Bundles can define scopes for distribution and deployment concerns:

#### Compliance Scope

Manages regulatory and organizational requirements:

```cue
#ComplianceScope: #BundleScope & {
    #metadata: #traits: ComplianceScope: {
        category: "contractual"
        provides: compliance: #ComplianceScope.compliance  
        scope: ["bundle"]
        requires: [
            "core.oam.dev/v1.PolicyEngine",
            "core.oam.dev/v1.AuditLog"
        ]
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

Applications define scopes and reference their components:

```cue
#Application: {
    name: string
    components: [string]: #Component
    
    // Scopes define cross-cutting concerns
    scopes?: {
        [ScopeName=string]: #ApplicationScope
    }
    
    // Policies can be defined separately for contractual traits
    policies?: {...}
}
```

### User Experience Examples

#### Basic Application with Network Scope

```cue
myApp: #Application & {
    name: "web-application"
    
    components: {
        frontend: #WebService & {
            workload: containers: main: image: "frontend:v1.0"
            expose: port: 3000
        }
        
        backend: #WebService & {
            workload: containers: main: image: "backend:v1.0"
            expose: port: 8080
        }
        
        database: #Database & {
            database: {
                type: "postgres"
                version: "14"
            }
        }
    }
    
    scopes: {
        webTier: #NetworkScope & {
            network: {
                components: ["frontend", "backend"]
                isolation: "namespace"
                serviceMesh: {
                    enabled: true
                    mTLS: true
                }
                ingress: [{
                    from: [{namespaceSelector: {}}]
                    ports: [{protocol: "TCP", port: 80}]
                }]
            }
        }
        
        dataLayer: #SecurityScope & {
            security: {
                components: ["database"]
                podSecurityContext: {
                    runAsNonRoot: true
                    runAsUser: 999
                }
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
        }
    }
    
    policies: {
        resourceLimits: #ResourceScope & {
            resources: {
                components: ["frontend", "backend", "database"]
                quota: {
                    cpu: "2000m"
                    memory: "4Gi"
                }
                limits: {
                    cpu: "500m"
                    memory: "1Gi"
                }
            }
        }
    }
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

Providers translate scope traits into platform-specific resources:

```cue
// Kubernetes provider handles scope traits
#KubernetesProvider: {
    scopes: {
        NetworkScope: {
            transform: (scope) => {
                // Create NetworkPolicy resources
                for component in scope.network.components {
                    "networkpolicy-\(component)": NetworkPolicy & {
                        metadata: name: "\(scope.metadata.name)-\(component)"
                        spec: {
                            podSelector: matchLabels: component: component
                            ingress: scope.network.ingress
                            egress: scope.network.egress
                        }
                    }
                }
                
                // Create service mesh resources if enabled
                if scope.network.serviceMesh.enabled {
                    "virtual-service": VirtualService & {
                        metadata: name: scope.metadata.name
                        spec: {
                            hosts: [for c in scope.network.components {"\(c).local"}]
                            http: [{
                                route: [{destination: host: component}] 
                                for component in scope.network.components
                            }]
                        }
                    }
                }
            }
        }
        
        SecurityScope: {
            transform: (scope) => {
                // Create RBAC resources
                if scope.security.rbac.enabled {
                    "service-account": ServiceAccount & {
                        metadata: name: scope.security.rbac.serviceAccount | scope.metadata.name
                    }
                    
                    "role": Role & {
                        metadata: name: scope.metadata.name
                        rules: scope.security.rbac.rules
                    }
                    
                    "role-binding": RoleBinding & {
                        metadata: name: scope.metadata.name
                        subjects: [{
                            kind: "ServiceAccount"
                            name: scope.security.rbac.serviceAccount | scope.metadata.name
                        }]
                        roleRef: {
                            kind: "Role"
                            name: scope.metadata.name
                        }
                    }
                }
                
                // Create Pod Security Policy
                if scope.security.podSecurityContext != _|_ {
                    "pod-security-policy": PodSecurityPolicy & {
                        metadata: name: scope.metadata.name
                        spec: {
                            runAsNonRoot: scope.security.podSecurityContext.runAsNonRoot
                            runAsUser: scope.security.podSecurityContext.runAsUser
                        }
                    }
                }
            }
        }
        
        ResourceScope: {
            transform: (scope) => {
                // Create ResourceQuota
                if scope.resources.quota != _|_ {
                    "resource-quota": ResourceQuota & {
                        metadata: name: scope.metadata.name
                        spec: hard: scope.resources.quota
                    }
                }
                
                // Create LimitRange
                if scope.resources.limits != _|_ {
                    "limit-range": LimitRange & {
                        metadata: name: scope.metadata.name
                        spec: limits: [{
                            type: "Container"
                            default: scope.resources.limits
                            defaultRequest: scope.resources.requests
                        }]
                    }
                }
            }
        }
    }
}
```

## Benefits

1. **Clear Separation**: Components focus on workload concerns, scopes handle cross-cutting concerns
2. **Trait Consistency**: Scopes use the same trait system as components
3. **Flexible Grouping**: Components can belong to multiple scopes for different concerns
4. **Platform Agnostic**: Scope definitions work across different deployment platforms
5. **Bundle Distribution**: Bundle-level scopes handle deployment and compliance concerns
6. **Provider Friendly**: Clear translation patterns for platform-specific implementations

## Implementation Plan

### Phase 1: Foundation

- [x] Define scope trait metadata patterns
- [x] Implement basic Application scope integration
- [ ] Create core scope types (Network, Security, Resource)
- [ ] Add scope validation and component reference checking

### Phase 2: Bundle Integration  

- [ ] Implement Bundle-level scope support
- [ ] Create distribution and compliance scope types
- [ ] Add bundle scope inheritance patterns

### Phase 3: Provider Support

- [ ] Implement Kubernetes scope transformers
- [ ] Add scope conflict resolution
- [ ] Create scope dependency validation

### Phase 4: Advanced Features

- [ ] Multi-scope component management
- [ ] Scope composition and inheritance
- [ ] Dynamic scope configuration

## Alternatives Considered

### Application-Level Traits

**Alternative**: Allow traits directly on Applications
**Rejected**: Breaks the clean architectural separation where Applications orchestrate rather than implement

### Component-Level Policy Duplication

**Alternative**: Apply all policies at individual component level
**Rejected**: Creates maintenance burden and inconsistency across related components

### Separate Scope Objects

**Alternative**: Define scopes outside the trait system
**Rejected**: Would fragment the unified trait architecture

## Conclusion

The scope system extends the unified trait architecture to handle cross-cutting concerns at Application and Bundle levels. By maintaining trait consistency while providing clear component grouping and policy application, scopes enable sophisticated operational management without compromising architectural clarity. The system supports both runtime operational concerns (Network, Security, Resource scopes) and distribution concerns (Bundle-level scopes) while maintaining provider flexibility and platform agnosticism.
