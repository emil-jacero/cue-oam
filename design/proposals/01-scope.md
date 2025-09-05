# CUE-OAM Design Document: Scope System Architecture

2025/01/09

**Status:** Draft
**Lifecycle:** Proposed
**Authors:** emil-jacero@
**Tracking Issue:** emil-jacero/cue-oam#[TBD]
**Related Roadmap Items:** Core Architecture, Component Model, Scope System
**Reviewers:** [TBD]
**Discussion:** GitHub Issue/PR #[TBD]

## Objective

Establish a comprehensive scope system that enables grouping and management of components with shared runtime characteristics, policies, and lifecycle concerns. Scopes provide a mechanism for cross-cutting operational concerns like networking, security, resource management, and deployment strategies that apply to multiple components collectively.

## Background

### Current State

CUE-OAM currently has a placeholder scope system with basic concepts defined in `core/v2alpha1/scope.cue`. The existing implementation includes:

- **Commented Implementation**: Basic `#ScopeInterface` with type categorization
- **Component Grouping**: Ability to list components by ID within a scope
- **Policy Integration**: Placeholder for applying policies to scoped components
- **Configuration Mutations**: Ability to apply common configurations to all components in scope

However, the current implementation lacks:

- Integration with the trait system
- Clear scope lifecycle management
- Provider integration patterns
- Practical scope implementations

### Problem Statement

Modern application deployment requires managing cross-cutting concerns that affect multiple components collectively:

1. **Network Isolation**: Components that need to share network policies, service meshes, or traffic routing
2. **Security Contexts**: Components requiring common security policies, RBAC rules, or compliance frameworks
3. **Resource Management**: Components sharing resource quotas, node affinity, or scaling policies
4. **Deployment Coordination**: Components with interdependencies, rollout strategies, or health checks
5. **Environment Consistency**: Components requiring consistent environment variables, secrets, or configuration

Example scenarios requiring scopes:

```cue
// Current limitation: No way to express shared concerns
frontend: #WebService & {...}
backend: #WebService & {...}
database: #Database & {...}

// Desired: Group components with shared networking/security
webTier: #NetworkScope & {
    components: ["frontend", "backend"]
    policies: [#TLSPolicy, #CORSPolicy]
}
```

### Goals

- [x] **Trait-Based Architecture**: Integrate scopes with the unified trait system
- [ ] **Comprehensive Scope Types**: Support networking, security, resource, and deployment scopes
- [ ] **Component Lifecycle Integration**: Manage scope-component relationships throughout application lifecycle
- [ ] **Policy Application**: Apply policies and configurations to all components within a scope
- [ ] **Provider Integration**: Enable platform-specific scope implementations
- [ ] **Inheritance and Composition**: Support scope hierarchies and trait composition patterns

### Non-Goals

- Runtime scope modification (focus on design-time composition)
- Component-to-scope automatic discovery (explicit assignment only)
- Cross-application scoping (scopes are application-scoped)
- Platform-specific scope optimizations (maintain platform agnostic design)

## Proposal

### CUE-OAM Model Impact

This design integrates scopes as trait-based entities within the CUE-OAM hierarchy:

- **New Traits**: Introduce scope-specific traits extending the base trait system
- **Component Changes**: Components reference scopes they belong to
- **Application Changes**: Applications define scopes alongside components
- **Bundle Integration**: Scopes can be defined at bundle level for cross-application concerns
- **Provider Requirements**: Providers must handle scope traits and their component relationships

### Core Scope Architecture

Scopes are implemented as specialized traits that group and manage components:

```cue
// Base scope trait extending the trait system
#ScopeBaseTrait: #ScopeTrait & {
    #metadata: {
        #traits: [string]: #TraitsMeta & {
            category: "scope"
        }
    }
    
    // Components belonging to this scope
    components!: [...#ComponentRef]
    
    // Policies to apply to all components
    policies?: [...#Policy]
    
    // Common mutations applied to all components
    apply?: {
        labels?:      #LabelsType
        annotations?: #AnnotationsType
        env?: [...#EnvVar]
        resources?:   #ResourceRequirements
    }
}

// Component reference within scopes
#ComponentRef: {
    id!:   string
    name?: string
    ...
}
```

### Scope Type Implementations

#### Network Scope

Manages network-related concerns for grouped components:

```cue
#NetworkScope: #ScopeBaseTrait & {
    #metadata: #traits: NetworkScope: {
        category: "scope"
        provides: network: #NetworkScope.network
        requires: [
            "core.oam.dev/v3alpha1.NetworkPolicy",
            "core.oam.dev/v3alpha1.ServiceMesh"
        ]
        description: "Manages network policies and service mesh configuration for components"
    }
    
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

Manages security policies and contexts:

```cue
#SecurityScope: #ScopeBaseTrait & {
    #metadata: #traits: SecurityScope: {
        category: "scope"
        provides: security: #SecurityScope.security
        requires: [
            "core.oam.dev/v3alpha1.SecurityPolicy",
            "core.oam.dev/v3alpha1.RBAC"
        ]
        description: "Manages security policies and RBAC for components"
    }
    
    security: {
        // Pod security context
        podSecurityContext?: #PodSecurityContext
        
        // Security policies
        policies?: [...#SecurityPolicy]
        
        // RBAC configuration
        rbac?: {
            enabled: bool | *false
            serviceAccount?: string
            rules?: [...#RBACRule]
        }
        
        // Network policies
        networkPolicies?: [...#NetworkPolicy]
        
        // Compliance frameworks
        compliance?: {
            frameworks?: [...("SOC2" | "PCI" | "HIPAA" | "GDPR")]
            scanning?: {
                enabled: bool | *false
                schedule?: string
            }
        }
    }
}
```

#### Resource Scope

Manages resource allocation and constraints:

```cue
#ResourceScope: #ScopeBaseTrait & {
    #metadata: #traits: ResourceScope: {
        category: "scope"
        provides: resources: #ResourceScope.resources
        requires: [
            "core.oam.dev/v3alpha1.ResourceQuota",
            "core.oam.dev/v3alpha1.LimitRange"
        ]
        description: "Manages resource quotas and limits for components"
    }
    
    resources: {
        // Resource quotas for the scope
        quota?: {
            cpu?:    string
            memory?: string
            storage?: string
            pods?:   int
        }
        
        // Default resource limits
        limits?: {
            cpu?:    string
            memory?: string
        }
        
        // Default resource requests
        requests?: {
            cpu?:    string
            memory?: string
        }
        
        // Node affinity/anti-affinity
        affinity?: #Affinity
        
        // Priority class
        priorityClass?: string
    }
}
```

#### Deployment Scope

Manages deployment strategies and lifecycle:

```cue
#DeploymentScope: #ScopeBaseTrait & {
    #metadata: #traits: DeploymentScope: {
        category: "scope"
        provides: deployment: #DeploymentScope.deployment
        requires: [
            "core.oam.dev/v3alpha1.DeploymentStrategy"
        ]
        description: "Manages deployment strategies and lifecycle for components"
    }
    
    deployment: {
        // Deployment strategy
        strategy: "RollingUpdate" | "Recreate" | "BlueGreen" | "Canary" | *"RollingUpdate"
        
        // Rolling update configuration
        rollingUpdate?: {
            maxUnavailable?: string | int
            maxSurge?:       string | int
        }
        
        // Canary deployment
        canary?: {
            steps?: [...#CanaryStep]
            trafficSplit?: {
                weight: int
                header?: string
            }
        }
        
        // Health checks
        healthChecks?: {
            readiness?: #Probe
            liveness?:  #Probe
            startup?:   #Probe
        }
        
        // Rollback configuration
        rollback?: {
            enabled: bool | *true
            onFailure?: bool | *true
            revision?: int
        }
    }
}
```

### Scope Integration in Applications

Applications define scopes and assign components to them:

```cue
#Application: #Object & {
    #kind: "Application"
    
    // Application components
    components: [string]: #Component
    
    // Application scopes
    scopes?: [string]: #ScopeBaseTrait
    
    // Scope assignments (alternative to component-level assignment)
    assignments?: {
        [ScopeName=string]: {
            components: [...string]  // Component IDs
        }
    }
}
```

### Component-Scope Relationships

Components can reference scopes they belong to:

```cue
#Component: #Object & {
    #kind: "Component"
    
    // Component traits
    [TraitName=string]: #ComponentTrait
    
    // Scope membership
    scopes?: [...string]  // Scope IDs this component belongs to
}
```

### User Experience Examples

#### Basic Network Scope Usage

```cue
myApp: #Application & {
    components: {
        frontend: #WebService & {
            scopes: ["web-tier"]
            // component definition
        }
        
        backend: #WebService & {
            scopes: ["web-tier", "secure-zone"]
            // component definition
        }
        
        database: #Database & {
            scopes: ["secure-zone"]
            // component definition
        }
    }
    
    scopes: {
        "web-tier": #NetworkScope & {
            components: [
                {id: "frontend"},
                {id: "backend"}
            ]
            network: {
                isolation: "namespace"
                serviceMesh: enabled: true
            }
        }
        
        "secure-zone": #SecurityScope & {
            components: [
                {id: "backend"},
                {id: "database"}
            ]
            security: {
                rbac: enabled: true
                compliance: frameworks: ["SOC2"]
            }
        }
    }
}
```

#### Multi-Scope Component Management

```cue
microservicesApp: #Application & {
    components: {
        apiGateway: #WebService & {scopes: ["public", "monitoring"]}
        userService: #WebService & {scopes: ["internal", "monitoring"]}
        orderService: #WebService & {scopes: ["internal", "monitoring"]}
        database: #Database & {scopes: ["data", "backup"]}
    }
    
    scopes: {
        public: #NetworkScope & {
            components: [{id: "apiGateway"}]
            network: {
                isolation: "pod"
                ingress: [
                    {
                        from: [{namespaceSelector: {}}]
                        ports: [{protocol: "TCP", port: 80}]
                    }
                ]
            }
        }
        
        internal: #NetworkScope & {
            components: [
                {id: "userService"},
                {id: "orderService"}
            ]
            network: {
                isolation: "namespace"
                serviceMesh: {
                    enabled: true
                    mTLS: true
                }
            }
        }
        
        monitoring: #ResourceScope & {
            components: [
                {id: "apiGateway"},
                {id: "userService"},
                {id: "orderService"}
            ]
            resources: {
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
        
        data: #SecurityScope & {
            components: [{id: "database"}]
            security: {
                compliance: frameworks: ["PCI", "SOC2"]
                rbac: {
                    enabled: true
                    rules: [
                        {
                            apiGroups: [""]
                            resources: ["secrets"]
                            verbs: ["get", "list"]
                        }
                    ]
                }
            }
        }
        
        backup: #DeploymentScope & {
            components: [{id: "database"}]
            deployment: {
                strategy: "Recreate"
                healthChecks: {
                    readiness: {
                        httpGet: {path: "/health", port: 5432}
                        initialDelaySeconds: 30
                    }
                }
            }
        }
    }
}
```

### Provider Integration

Providers translate scope traits to platform-specific resources:

```cue
#KubernetesProvider: {
    scope: {
        "NetworkScope": #NetworkScopeTransformer & {
            transform: (scope) => {
                if scope.network.serviceMesh.enabled {
                    VirtualService: {...}
                    DestinationRule: {...}
                }
                if scope.network.isolation != "none" {
                    NetworkPolicy: {...}
                }
            }
        }
        
        "SecurityScope": #SecurityScopeTransformer & {
            transform: (scope) => {
                if scope.security.rbac.enabled {
                    ServiceAccount: {...}
                    Role: {...}
                    RoleBinding: {...}
                }
                if scope.security.compliance != _|_ {
                    PodSecurityPolicy: {...}
                }
            }
        }
        
        "ResourceScope": #ResourceScopeTransformer & {
            transform: (scope) => {
                ResourceQuota: {...}
                LimitRange: {...}
            }
        }
        
        "DeploymentScope": #DeploymentScopeTransformer & {
            transform: (scope) => {
                // Applied as deployment strategy to all components
                // No direct Kubernetes resource, affects Deployment spec
            }
        }
    }
}
```

## Implementation Plan

### Phase 1: Foundation (Next)

- [ ] Define base `#ScopeBaseTrait` structure
- [ ] Implement core scope types (`#NetworkScope`, `#SecurityScope`, `#ResourceScope`)
- [ ] Add scope integration to `#Application` and `#Component`
- [ ] Create basic scope-component relationship validation

### Phase 2: Provider Integration (Future)

- [ ] Implement Kubernetes scope transformers
- [ ] Add Docker Compose scope support (where applicable)
- [ ] Create scope conflict resolution mechanisms
- [ ] Add scope dependency validation

### Phase 3: Advanced Features (Future)

- [ ] Implement `#DeploymentScope` with complex strategies
- [ ] Add scope inheritance and composition patterns
- [ ] Create scope lifecycle management (creation, updates, deletion)
- [ ] Add scope monitoring and observability

### Phase 4: Ecosystem Integration (Future)

- [ ] Integrate with external policy engines (OPA, Kyverno)
- [ ] Add service mesh integration (Istio, Linkerd)
- [ ] Support for GitOps scope management
- [ ] Scope template and reusability patterns

## Alternatives Considered

### Component-Level Policy Application

**Alternative**: Apply all policies directly at the component level
**Rejected**: Creates duplication and inconsistency across related components. Scopes provide better abstraction for shared concerns.

### Namespace-Only Grouping

**Alternative**: Use only Kubernetes namespaces for component grouping
**Rejected**: Too restrictive and platform-specific. Scopes provide more flexible, platform-agnostic grouping.

### Separate Scope Objects

**Alternative**: Define scopes as separate top-level objects outside the trait system
**Rejected**: Would fragment the system and lose trait composition benefits.

## Future Considerations

### Cross-Application Scopes

- Bundle-level scopes that span multiple applications
- Shared infrastructure scopes (monitoring, logging, security)
- Multi-tenancy scope management

### Dynamic Scope Management

- Runtime scope modification capabilities
- Auto-discovery of component scope requirements
- Intelligent scope assignment based on component characteristics

### Advanced Policy Integration

- Policy validation and conflict resolution
- Policy templates and inheritance
- Integration with external compliance frameworks

## Related Work

- **Kubernetes Namespaces**: Basic grouping and isolation
- **Istio VirtualServices**: Service mesh traffic management
- **OPA/Gatekeeper**: Policy enforcement frameworks
- **Helm Dependencies**: Application component relationships
- **Crossplane Composition**: Resource grouping and management
