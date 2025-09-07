# OPM (Open Platform Model) Design Document: Promise System Architecture

2025-09-06

**Status:** Incoherent Rambling
**Lifecycle:** Ideation
**Authors:** <emil@jacero.se>
**Tracking Issue:** emil-jacero/opm#[TBD]
**Related Roadmap Items:** Platform Capabilities, Self-Service Infrastructure, Developer Experience
**Reviewers:** [TBD]
**Discussion:** GitHub Issue/PR #[TBD]

## Objective

Establish a Promise system that transforms OPM (Open Platform Model) into a comprehensive platform-building tool by providing self-service APIs that abstract ANY Kubernetes resource complexity - from applications to infrastructure to entire environments - while maintaining governance, leveraging KCP for multi-tenancy, and enabling platform teams to offer curated services that end-users can consume without deep technical knowledge.

## Background

### Current State

OPM currently provides powerful abstractions through traits, components, and applications, primarily focused on application deployment. However, modern platforms require more than just application management - they need to provision infrastructure, create tenants, install operators, and manage entire environments.

Currently, platform teams must:

- Use different tools for different resource types (Helm for apps, Crossplane for infrastructure, ClusterAPI for clusters)
- Manually coordinate between these tools
- Build custom abstractions for each use case
- Struggle to provide unified self-service experiences

End-users must understand multiple tools and their interactions to get a complete environment.

### Problem Statement

Modern platform engineering requires bridging the gap between powerful infrastructure primitives and user-friendly consumption:

1. **Cognitive Load**: Developers want to focus on applications, not infrastructure details
2. **Standardization**: Platform teams need to enforce organizational standards across ALL resource types
3. **Self-Service Everything**: Users expect on-demand provisioning of applications, infrastructure, and entire environments
4. **Unified Experience**: Users shouldn't need to learn different tools for different resources
5. **Governance**: Compliance and security must be transparent and automatic across all provisioned resources
6. **Evolution**: Platform capabilities must evolve without breaking user experiences
7. **Multi-Tenancy**: Teams need isolated environments with controlled resource sharing - addressed by KCP integration

### Industry Context

The Promise pattern is inspired by successful platform-as-a-product approaches, particularly Kratix Promises which encapsulate complexity behind simple APIs. Similar patterns exist in Crossplane Compositions, AWS Service Catalog, and Backstage Templates.

**KCP as Foundation**: By leveraging KCP (kcp.io) for multi-tenancy, OPM can focus on the application model and service catalog while KCP provides:

- Logical isolation through workspaces
- Multi-cluster capabilities
- API compatibility with Kubernetes
- Cross-workspace resource sharing

### Why KCP?

KCP (kcp.io) provides the ideal foundation for OPM's multi-tenant promise system because:

1. **Native Multi-Tenancy**: Workspaces provide hard isolation between tenants
2. **Kubernetes Compatible**: Maintains API compatibility while adding logical isolation
3. **Hierarchical Organization**: Workspace trees map naturally to organizational structures
4. **Cross-Workspace Sharing**: Enables promise catalogs to be shared while maintaining isolation
5. **Virtual Clusters**: Future capability for even stronger isolation when needed

By delegating multi-tenancy to KCP, OPM can focus on its core value: simplifying cloud-native application deployment through abstractions and service catalogs.

### Goals

- [ ] **Universal Service Abstraction**: Hide complexity of ANY Kubernetes resource behind simple APIs
- [ ] **Platform Catalog**: Create discoverable catalog of applications, infrastructure, and platform capabilities
- [ ] **Automated Governance**: Transparently enforce policies across all resource types
- [ ] **Workflow Orchestration**: Support complex provisioning for applications and infrastructure
- [ ] **KCP Integration**: Leverage KCP for multi-tenancy and enable tenant self-provisioning
- [ ] **Progressive Disclosure**: Allow advanced users to access more complexity when needed
- [ ] **Infrastructure as Code**: Enable platform teams to offer IaC through simple promises

### Non-Goals

- Replacing existing OPM abstractions (Promises build on top of them)
- Creating a rigid PaaS (maintaining flexibility is crucial)
- Implementing multi-tenancy (delegated to KCP)
- Automated promise generation from applications
- Cross-cluster promise federation (beyond KCP's capabilities in initial scope)

## Proposal

### OPM Model Impact

Promises introduce a new abstraction layer that can generate ANY Kubernetes resources:

```shell
KCP Workspace (Tenant Isolation)
    └── Promise (Platform API Layer)
            └── generates → Application/Bundle (OPM native)
                              ├── Components (with Traits)
                              ├── Scopes
                              ├── Policies
                              ├── generates → Infrastructure (via integrations)
                              │               ├── ClusterAPI Clusters
                              │               ├── Crossplane Resources
                              │               └── Cloud Resources
                              ├── generates → Platform Resources
                              │               ├── KCP Workspaces (new tenants)
                              │               ├── Operators/Controllers
                              │               └── CRDs
                              └── generates → Raw Kubernetes Resources
                                              └── Any valid K8s manifest
```

**New Types:**

- `#Promise`: Service catalog entry that can provision ANY Kubernetes resources
- `#PromiseRequest`: User request for a promise
- `#PromiseCatalog`: Registry and discovery system
- `#PromiseWorkflow`: Provisioning orchestration

**Resource Types Promises Can Generate:**

- OPM Applications and Bundles (native)
- ClusterAPI resources (clusters, machine pools)
- Crossplane compositions (cloud infrastructure)
- KCP workspaces (new tenants)
- Kubernetes operators and CRDs
- Raw Kubernetes manifests
- Any combination of the above

**KCP Integration:**

- Leverages KCP workspaces for multi-tenancy
- Each team/tenant gets isolated workspaces
- Promises can create new workspaces (tenant provisioning)
- Resource isolation handled at KCP level

### Core Concepts

#### Promise Structure

A Promise encapsulates:

- **API Definition**: Simple parameters exposed to users
- **Implementation**: Can be an Application, Bundle, or ANY Kubernetes resources
- **Workflows**: Provisioning and lifecycle management steps
- **Policies**: Platform-defined rules and behaviors that are automatically applied
- **Governance**: Automatic compliance and security enforcement

#### Promise Flexibility

Promises are not limited to applications - they can describe and provision ANY Kubernetes resources:

- **Applications**: Traditional OPM applications with components and traits
- **Infrastructure**: ClusterAPI clusters, cloud resources via Crossplane
- **Tenants**: New KCP workspaces or virtual clusters
- **Platform Capabilities**: Operators, CRDs, controllers
- **Complete Environments**: Full development environments with clusters, namespaces, and applications

For example, a "new-tenant" promise could:

1. Create a new KCP workspace
2. Provision a dedicated cluster via ClusterAPI
3. Install required operators
4. Set up networking and security policies
5. Deploy initial applications

The actual implementation might leverage Crossplane compositions, ClusterAPI templates, or raw Kubernetes manifests - the Promise abstracts all of this complexity.

#### Policy Enforcement at Promise Level

Platform teams can attach policies directly to promises to:

- **Enforce Behaviors**: Mandate specific deployment strategies, update patterns, or operational practices
- **Apply Constraints**: Set resource limits, scaling boundaries, or availability requirements
- **Ensure Compliance**: Automatically apply security policies, audit logging, or regulatory requirements
- **Control Lifecycle**: Define backup schedules, retention policies, or maintenance windows

These policies are transparent to end-users but always enforced when the promise is fulfilled, regardless of whether the promise provisions an application, infrastructure, or an entire tenant.

#### OPM Traits for Infrastructure

While traditionally used for applications, OPM traits can also describe infrastructure:

- A `#ClusterAPI` trait could define cluster specifications
- A `#CrossplaneResource` trait could define cloud resources  
- A `#KCPWorkspace` trait could define tenant configurations
- A `#OperatorInstall` trait could define operator deployments

This means platform teams can use the same OPM patterns for both applications AND infrastructure promises, creating a truly unified model where everything is a trait-based resource that can be composed, validated, and governed consistently.

#### Parameter Abstraction

Promises translate simple user inputs into complex configurations:

**Application Example:**

- **User provides**: `tier: "production"`, `size: "large"`
- **Promise generates**: Full application with appropriate resources, replicas, monitoring, backups
- **Platform adds**: Security policies, compliance rules, operational constraints

**Infrastructure Example:**

- **User provides**: `region: "us-west"`, `ha: true`
- **Promise generates**: Multi-AZ RDS via Crossplane, VPC configuration, security groups
- **Platform adds**: Encryption requirements, backup policies, network restrictions

**Tenant Example:**

- **User provides**: `team: "backend"`, `environment: "development"`
- **Promise generates**: KCP workspace, ClusterAPI cluster, RBAC, quotas, initial operators
- **Platform adds**: Cost controls, compliance policies, audit logging

#### Workflow System

Promises include workflow definitions for:

- Validation and capacity checks
- Resource provisioning within KCP workspaces
- Configuration steps
- Health verification
- Cross-workspace resource coordination
- Day-2 operations (backup, restore, scale)

#### Multi-Tenancy via KCP

OPM leverages KCP (Kubernetes Control Plane) for multi-tenancy:

- **Workspace Isolation**: Each team/tenant operates in isolated KCP workspaces
- **Resource Segregation**: KCP handles resource isolation and access control
- **Cross-Workspace Sharing**: Promises can be published to shared workspaces for consumption
- **Hierarchical Organization**: KCP's workspace hierarchy maps to organizational structure

This approach means OPM focuses on the promise/service catalog layer while KCP provides the foundational multi-tenancy capabilities.

### User Experience Vision

#### Platform Team Experience

Platform teams create Promises that:

- Define simple parameter schemas for users
- Map parameters to ANY Kubernetes resources (not just applications)
- **Attach policies that enforce organizational standards**
- **Define mandatory operational behaviors (backup, scaling, security)**
- Include operational best practices
- **Control resource consumption and deployment patterns**
- Ensure compliance without user intervention

Example Promise Types Platform Teams Can Create:

- **Application Promises**: Traditional applications with databases, services, etc.
- **Tenant Promises**: Complete isolated environments with dedicated clusters
- **Infrastructure Promises**: Cloud resources, networks, storage via Crossplane
- **Platform Capability Promises**: Operators, service meshes, observability stacks
- **Development Environment Promises**: Complete dev setups with IDEs, tools, and resources

Platform teams have full control over what policies are applied to each promise, making it impossible for users to bypass organizational requirements while still providing a simple, self-service experience.

#### End-User Experience

End-users interact with Promises through:

- Simple parameter-based requests
- Service catalog browsing
- Self-service provisioning
- Clear documentation and examples

#### Example Interaction Flow

**Scenario 1: Application Deployment**

1. User browses catalog in their workspace: `opm promise list`
2. User explores promise: `opm promise describe postgresql`
3. User requests service: `opm promise request postgresql --tier production`
4. Platform automatically provisions the database application

**Scenario 2: New Tenant Provisioning**

1. Team lead browses catalog: `opm promise list`
2. Sees "new-tenant" promise: `opm promise describe new-tenant`
3. Requests new tenant: `opm promise request new-tenant --team backend --size medium`
4. Platform automatically:
   - Creates new KCP workspace
   - Provisions dedicated cluster via ClusterAPI
   - Installs required operators
   - Sets up networking and policies
   - Configures RBAC and quotas
   - Returns workspace credentials and endpoints

In both scenarios, the platform:

- Validates request against permissions
- Checks resource availability
- **Applies platform-defined policies**
- **Enforces security and compliance rules**
- Handles all complexity transparently

### Separation of Concerns

**Users Control:**

- Which promise to use (from available in their workspace)
- Basic parameters (tier, size, version, region, etc.)
- Instance naming
- When to provision/deprovision

**Platform Teams Control (via Promise):**

- What resources are actually provisioned (apps, infrastructure, clusters, tenants)
- Resource allocation and limits across all resource types
- Security policies and network rules
- Backup and disaster recovery policies
- Compliance and audit requirements
- Update and maintenance strategies
- Cost controls and quotas
- Operational behaviors and constraints
- Which underlying tools are used (Crossplane, ClusterAPI, etc.)

**KCP Controls:**

- Workspace isolation and boundaries
- Cross-workspace resource sharing permissions
- Team/tenant separation
- Resource quotas at workspace level

This separation ensures platform teams maintain governance while users get self-service capabilities within their isolated workspaces, regardless of whether they're provisioning a simple application or an entire development environment.

## Implementation Considerations

### Promise Definition

Promises need to define:

- Metadata (name, version, description, maintainer)
- User-facing API (parameters, examples, outputs)
- Implementation (can be ANY of the following):
  - OPM Application/Bundle
  - ClusterAPI cluster definitions
  - Crossplane compositions
  - KCP workspace configurations
  - Raw Kubernetes manifests
  - Combinations of the above
- **Platform policies (resource limits, security rules, operational requirements)**
- Workflows (provisioning steps)
- Dependencies (required platform capabilities)

The key distinction is that policies are defined by the platform team at the promise level, not by end-users. This ensures consistent governance across all instances of a promise, regardless of what type of resources it provisions.

### Catalog System

The catalog needs to support:

- Promise registration and versioning
- Search and discovery across workspaces
- Documentation generation
- Category organization
- Workspace-aware promise visibility (which promises are available in which workspaces)

### Workflow Engine

Workflows need to support:

- Sequential and parallel steps
- Conditional execution
- Error handling and rollback
- State management
- External integrations

### Integration with Infrastructure Tools

OPM Promises act as an orchestration layer over existing tools:

**ClusterAPI Integration:**

- Promises can template ClusterAPI manifests
- Workflows orchestrate cluster provisioning
- Users just specify size and region

**Crossplane Integration:**

- Promises can reference Crossplane compositions
- Complex cloud resources become simple parameters
- Governance policies automatically applied

**Operator Integration:**

- Promises can install and configure operators
- Chain operator installations with application deployments
- Hide operator complexity from end-users

This approach means OPM doesn't reinvent infrastructure provisioning - it provides a unified, user-friendly layer over best-of-breed tools.

### Governance Integration

Promises automatically enforce governance through:

- **Policy Injection**: Platform-defined policies attached to promises
- **Security Controls**: Automatic security policy application
- **Compliance Requirements**: Regulatory and organizational compliance
- **Workspace Boundaries**: KCP enforces isolation between tenants

### KCP Integration

OPM will integrate with KCP to provide:

- **Workspace Management**: Teams get isolated workspaces for their resources
- **Promise Distribution**: Platform teams publish promises to shared/parent workspaces
- **Resource Isolation**: Each workspace has its own resources and quotas
- **Cross-Workspace References**: Promises can reference resources across workspace boundaries when needed

This integration allows OPM to focus on the application model and service catalog while KCP handles the complex multi-tenancy concerns.

## Alternatives Considered

### Helm-style Values Files

**Why not**: No parameter validation, no workflow orchestration, poor discoverability, limited to application templates

### Kubernetes Operators

**Why not**: High development overhead, typically single-purpose, complex for end-users, can't provision infrastructure outside their domain

### Traditional Templates

**Why not**: No type safety, no constraint validation, difficult to compose, can't handle complex workflows

### Pure Crossplane/ClusterAPI

**Why not**: Too low-level for end-users, no unified catalog, requires deep knowledge of each tool

### Advantage of OPM Promises

Promises provide a unified abstraction over ALL these approaches - they can leverage Helm charts, trigger operators, use Crossplane compositions, orchestrate ClusterAPI, and combine them all behind a simple user interface.

## Future Considerations

### Advanced Features

- Promise composition (promises using other promises)
- Hierarchical promises (tenant promise includes default application promises)
- Cross-workspace promise dependencies via KCP
- Cost estimation and optimization for infrastructure promises
- AI-assisted parameter recommendations

### Infrastructure as Code Evolution

- GitOps-based promise definitions
- Terraform/OpenTofu integration for non-Kubernetes resources
- Pulumi integration for programmatic infrastructure
- Integration with existing IaC tools

### KCP Evolution

- Leveraging KCP's virtual cluster capabilities
- Cross-cluster promise fulfillment through KCP
- Hierarchical workspace templates via promises
- Advanced RBAC through KCP's permission model

### Ecosystem

- Community promise marketplace (applications, infrastructure, platforms)
- Vendor-certified promises (databases, cloud services, SaaS)
- Integration with existing tools (Backstage, ArgoCD, Flux)
- KCP-aware GitOps workflows

## Related Work

- **KCP (kcp.io)**: Provides multi-tenancy and workspace isolation foundation
- **Kratix Promises**: Direct inspiration for the promise model
- **Crossplane**: Infrastructure provisioning that promises can leverage
- **ClusterAPI**: Kubernetes cluster provisioning that promises can orchestrate
- **AWS Service Catalog**: Enterprise service catalog model
- **Backstage Software Templates**: Developer portal integration patterns
- **Terraform/OpenTofu**: Infrastructure as code that could be integrated

## Open Questions

1. How should promises handle version upgrades of deployed resources?
2. Should promises support imperative actions or remain purely declarative?
3. How to balance simplicity with flexibility for advanced users?
4. What's the best way to handle promise dependencies?
5. How to integrate with existing GitOps workflows?
6. Should platform policies be composable across promises or promise-specific?
7. How to handle policy conflicts when multiple policies apply?
8. Should users be able to see what policies are being applied to their resources?
9. How should promises be shared across KCP workspaces?
10. Should promise catalogs be workspace-specific or global?
11. How to handle cross-workspace resource references in promises?
12. Should infrastructure promises (ClusterAPI, Crossplane) use OPM traits or raw manifests?
13. How to handle promise types that provision resources outside Kubernetes?
14. What's the governance model for tenant-provisioning promises?
15. How to handle cost tracking and chargeback for infrastructure promises?

## Next Steps

1. Validate concept with platform teams and end-users
2. Design detailed Promise schema that supports multiple resource types
3. Prototype basic promise-to-application rendering
4. Prototype promise-to-infrastructure rendering (ClusterAPI, Crossplane)
5. Explore workflow engine options for complex orchestration
6. Define catalog structure and discovery mechanisms
7. Investigate KCP integration patterns and workspace strategies
8. Design promise distribution across KCP workspaces
9. Create example promises for applications, infrastructure, and tenants
10. Test integration with existing infrastructure tools

## Conclusion

The Promise system transforms OPM (Open Platform Model) into a universal platform-building toolkit that can abstract ANY Kubernetes resource - from simple applications to complex infrastructure to entire tenant environments. By treating everything as a promise with simple parameters, platform teams can offer true self-service while maintaining complete control over governance, security, and compliance.

This approach unifies the fragmented landscape of cloud-native tools (Helm, Crossplane, ClusterAPI, operators) behind a single, consistent interface. Users don't need to know whether they're provisioning an application via OPM traits, infrastructure via Crossplane, or a cluster via ClusterAPI - they just request what they need through promises.

Combined with KCP for multi-tenancy, OPM becomes a complete platform engineering solution that scales from simple applications to complex, multi-tenant, multi-cluster environments.
