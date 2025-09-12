# Domain Restructure Proposal

## Executive Summary

This proposal introduces a streamlined domain structure for organizing traits in the CUE-OAM system. The new structure reduces complexity from 8 domains to 6, with each domain having a clear, distinct purpose that aligns with common operational concerns in cloud-native applications.

## New Domain Structure

### 1. Workload Domain

**Description**: The Workload domain encompasses all traits related to application runtime, execution models, and lifecycle management. These traits define HOW applications run.

**Reason for Existing**: Every application needs to define its execution model. This domain provides a clear home for all runtime-related concerns, from simple container specifications to complex orchestration patterns.

**Examples of Traits**:

- `ContainerSet` - Defines containers and their configurations
- `Replica` - Specifies instance count and replication strategies
- `RestartPolicy` - Defines failure recovery behaviors
- `UpdateStrategy` - Controls rollout and deployment patterns
- `Job` - One-time execution workloads
- `CronJob` - Scheduled recurring workloads
- `Deployment` - Stateless application deployments
- `StatefulSet` - Stateful application deployments
- `DaemonSet` - Node-level system services

### 2. Data Domain

**Description**: The Data domain covers all aspects of state management, configuration, and persistence. These traits define WHAT data applications need and HOW it's stored.

**Reason for Existing**: Applications require various forms of data - from configuration and secrets to persistent storage. This domain provides a unified approach to all data-related concerns, making it easy to understand an application's state requirements.

**Examples of Traits**:

- `Volume` - Persistent and ephemeral storage volumes
- `Config` - Application configuration management
- `Secret` - Sensitive data and credentials
- `PersistentVolumeClaim` - Storage provisioning requests
- `StorageClass` - Storage tier definitions
- `ConfigMap` - Configuration data for pods
- `Database` - Managed database instances
- `Cache` - In-memory data stores
- `Backup` - Data backup and recovery policies

### 3. Connectivity Domain

**Description**: The Connectivity domain manages all aspects of networking, service discovery, and external integration. These traits define HOW applications communicate.

**Reason for Existing**: Modern applications are inherently distributed and need sophisticated networking capabilities. This domain consolidates all connectivity concerns, from basic service exposure to complex mesh configurations.

**Examples of Traits**:

- `Expose` - Service exposure and load balancing
- `Service` - Internal service discovery
- `Ingress` - External HTTP/HTTPS routing
- `NetworkPolicy` - Network segmentation and firewall rules
- `NetworkIsolation` - Network boundary enforcement
- `SharedNetwork` - Shared networking contexts
- `ServiceMesh` - Advanced traffic management
- `APIGateway` - API management and routing
- `MessageQueue` - Asynchronous messaging
- `ExternalService` - External service dependencies

### 4. Security Domain

**Description**: The Security domain encompasses authentication, authorization, encryption, and protection mechanisms. These traits define HOW applications are secured.

**Reason for Existing**: Security is a critical cross-cutting concern that deserves its own domain. This provides a clear location for all security-related configurations, making it easier to audit and maintain security postures.

**Examples of Traits**:

- `ServiceAccount` - Workload identity
- `Role` - Namespace-scoped permissions
- `ClusterRole` - Cluster-wide permissions
- `RoleBinding` - Permission assignments
- `SecurityContext` - Container security settings
- `PodSecurityPolicy` - Pod security standards
- `NetworkPolicy` - Network-level security
- `TLS` - Transport layer security
- `Encryption` - Data encryption policies
- `SecretRotation` - Credential rotation policies

### 5. Observability Domain

**Description**: The Observability domain provides visibility into application behavior through monitoring, logging, and tracing. These traits define HOW applications are observed.

**Reason for Existing**: Understanding application behavior is crucial for operations. This domain consolidates all observability concerns, making it easy to implement comprehensive monitoring strategies.

**Examples of Traits**:

- `ServiceMonitor` - Metrics collection endpoints
- `PodMonitor` - Pod-level metrics
- `Logging` - Log aggregation and management
- `Tracing` - Distributed request tracing
- `Profiling` - Performance profiling
- `HealthCheck` - Liveness and readiness probes
- `Alerts` - Alert rules and notifications
- `Dashboard` - Visualization configurations
- `AuditLog` - Audit trail management
- `Events` - Event streaming and processing

### 6. Governance Domain

**Description**: The Governance domain enforces organizational policies, resource constraints, and compliance requirements. These traits define WHAT rules and limits apply.

**Reason for Existing**: Organizations need to enforce standards, control resource usage, and ensure compliance. This domain provides a clear structure for all governance-related concerns, from resource quotas to compliance policies.

**Examples of Traits**:

- `ResourceQuota` - Resource consumption limits
- `LimitRange` - Min/max resource boundaries
- `PodDisruptionBudget` - Availability guarantees
- `PriorityClass` - Workload prioritization
- `NamespaceQuota` - Namespace-level constraints
- `CompliancePolicy` - Regulatory compliance rules
- `CostManagement` - Cost allocation and limits
- `MaintenanceWindow` - Scheduled maintenance policies
- `RetentionPolicy` - Data retention rules
- `SLA` - Service level agreements

## Migration Strategy

### Phase 1: Documentation Update

1. Update all documentation to reflect new domains
2. Create mapping guide from old to new domains

### Phase 2: Code Updates

1. Update core trait definitions
2. Modify trait.cue domain enums
3. Update provider mappings

### Phase 3: Catalog Reorganization

1. Create new folder structure
2. Move traits to appropriate domains
3. Update import paths

### Phase 4: Validation

1. Test all examples with new structure
2. Verify provider compatibility
3. Update CI/CD pipelines

## Benefits

1. **Clarity**: Each domain has a single, clear purpose
2. **Discoverability**: Developers can easily find relevant traits
3. **Maintainability**: Clear boundaries reduce overlap and confusion
4. **Scalability**: New traits have obvious homes
5. **Alignment**: Matches common operational mental models

## Compatibility

The new domain structure maintains backward compatibility through:

- Trait interfaces remain unchanged
- Only metadata domain field is updated
- Providers continue to work without modification

## Domain Mapping from Old to New

| Old Domain | New Domain | Rationale |
|------------|------------|-----------|
| Operational | Workload | More specific to runtime concerns |
| Resource | Data | Clearer focus on state and configuration |
| Structural | Connectivity | Better describes networking purpose |
| Security | Security | Remains unchanged - already clear |
| Observability | Observability | Remains unchanged - already clear |
| Contractual | Governance | Broader term for all constraints |
| Behavioral | Workload/Governance | Split based on runtime vs policy |
| Integration | Connectivity | Consolidated with networking |

## Conclusion

This domain restructure provides a cleaner, more intuitive organization that aligns with how teams think about cloud-native applications. The six domains - Workload, Data, Connectivity, Security, Observability, and Governance - cover all aspects of application deployment while maintaining clear boundaries and purposes.
