# Example Composite Traits Catalog

This document provides a comprehensive list of all composite traits in the CUE-OAM system. Composite traits are built by combining atomic traits and/or other composite traits to provide higher-level, multi-faceted functionality.

## Overview

Composite traits are characterized by:

- `type: "composite"` in their metadata
- Presence of `composes` field listing constituent traits
- Automatically computed `requiredCapabilities` from composed traits
- Maximum composition depth of 3 levels
- Combining multiple concerns into cohesive units

## Operational Composite Traits

Higher-level operational patterns built from multiple atomic traits.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **WebService** | Operational | `Workload`, `Replicable`, `Route`, `HealthCheck` | Long-running, scalable web service with HTTP endpoint |
| **APIService** | Operational | `Workload`, `Replicable`, `Route`, `RateLimiter`, `Metrics` | API service with rate limiting and metrics |
| **Worker** | Operational | `Workload`, `Replicable`, `Queue` | Background worker processing queue messages |
| **ScheduledTask** | Operational | `CronJob`, `Config`, `Secret` | Scheduled task with configuration |
| **BatchJob** | Operational | `Job`, `Volume`, `Config` | Batch processing job with storage |
| **StatefulService** | Operational | `Workload`, `Volume`, `ServiceDiscovery`, `BackupPolicy` | Stateful service with persistent storage |
| **Daemon** | Operational | `Workload`, `HostNetwork`, `Toleration` | System daemon running on every node |
| **EdgeService** | Operational | `Workload`, `Ingress`, `Certificate`, `RateLimiter` | Edge service with TLS and rate limiting |
| **MicroService** | Operational | `Workload`, `ServiceMesh`, `Tracing`, `Metrics` | Microservice with full observability |
| **ServerlessFunction** | Operational | `EventTrigger`, `Autoscaler`, `Timeout` | Event-driven serverless function |

## Resource Composite Traits

Complex resource management patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **Database** | Resource | `Workload`, `Volume`, `Secret`, `BackupPolicy` | Database with persistent storage and backups |
| **CacheLayer** | Resource | `Workload`, `Volume`, `Config` | Caching layer with configuration |
| **MessageBroker** | Resource | `Workload`, `Volume`, `NetworkPolicy`, `Certificate` | Message broker with secure networking |
| **DataPipeline** | Resource | `Job`, `Volume`, `Migration`, `Schema` | Data processing pipeline |
| **StorageCluster** | Resource | `StatefulService`, `DataReplication`, `Snapshot` | Distributed storage cluster |
| **SecretStore** | Resource | `Secret`, `Certificate`, `KeyVault` | Centralized secret management |
| **ConfigurationHub** | Resource | `Config`, `Volume`, `VersionControl` | Configuration management hub |
| **DataLake** | Resource | `ObjectStorage`, `Schema`, `DataGovernance` | Data lake with governance |

## Structural Composite Traits

Complex networking and organizational patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **ServiceEndpoint** | Structural | `Route`, `LoadBalancer`, `HealthCheck` | Service with load balancing and health checks |
| **SecureGateway** | Structural | `Gateway`, `Certificate`, `SecurityPolicy`, `RateLimiter` | Secure API gateway |
| **ServiceMeshEnabled** | Structural | `ServiceMesh`, `Tracing`, `CircuitBreaker`, `Retry` | Service mesh with resilience patterns |
| **NetworkZone** | Structural | `NetworkPolicy`, `NetworkIsolationScope`, `DNSPolicy` | Isolated network zone |
| **MultiRegionService** | Structural | `Workload`, `AffinityRules`, `TopologySpread`, `LoadBalancer` | Service distributed across regions |
| **IngressController** | Structural | `Ingress`, `Certificate`, `RateLimiter`, `Metrics` | Full ingress controller setup |
| **ServiceRegistry** | Structural | `ServiceDiscovery`, `HealthCheck`, `Metrics` | Service registry with health monitoring |

## Behavioral Composite Traits

Advanced behavioral and resilience patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **ResilientService** | Behavioral | `CircuitBreaker`, `Retry`, `Timeout`, `Fallback` | Service with full resilience patterns |
| **AsyncProcessor** | Behavioral | `Queue`, `EventTrigger`, `Retry`, `DeadLetter` | Asynchronous message processor |
| **ThrottledAPI** | Behavioral | `RateLimiter`, `Throttle`, `Bulkhead`, `Cache` | API with comprehensive throttling |
| **EventDrivenService** | Behavioral | `EventTrigger`, `Queue`, `Retry`, `CircuitBreaker` | Event-driven service with resilience |
| **CachedEndpoint** | Behavioral | `Route`, `Cache`, `Timeout`, `Metrics` | Endpoint with caching layer |
| **SagaOrchestrator** | Behavioral | `Workload`, `Queue`, `Retry`, `CompensationHandler` | Saga pattern orchestrator |
| **StreamProcessor** | Behavioral | `EventTrigger`, `BatchProcessor`, `Debounce` | Stream processing service |

## Contractual Composite Traits

Governance and compliance patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **SecureWorkload** | Contractual | `Workload`, `SecurityPolicy`, `SecurityContext`, `RBAC` | Workload with comprehensive security |
| **CompliantService** | Contractual | `CompliancePolicy`, `Audit`, `DataGovernance`, `Encryption` | Service meeting compliance requirements |
| **RegulatedDatabase** | Contractual | `Database`, `CompliancePolicy`, `Audit`, `BackupPolicy` | Database with regulatory compliance |
| **HighAvailabilityService** | Contractual | `Workload`, `PodDisruptionBudget`, `SLA`, `Replicable` | Service with HA guarantees |
| **CostOptimizedWorkload** | Contractual | `Workload`, `CostControl`, `ResourceQuota`, `Autoscaler` | Cost-optimized workload |
| **MultiTenantService** | Contractual | `Workload`, `NetworkSegmentation`, `ResourceQuota`, `RBAC` | Multi-tenant service with isolation |

## Observability Composite Traits

Full-stack observability patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **ObservableService** | Observability | `Metrics`, `Logging`, `Tracing`, `Dashboard` | Service with full observability |
| **MonitoredDatabase** | Observability | `Database`, `Metrics`, `Alerts`, `Dashboard` | Database with monitoring stack |
| **APMEnabled** | Observability | `Tracing`, `Metrics`, `Profiling`, `ErrorTracking` | Application performance monitoring |
| **LogAggregator** | Observability | `Logging`, `Volume`, `Dashboard`, `Alerts` | Centralized log aggregation |

## Platform Composite Traits

Platform-specific composite patterns.

| Trait | Category | Composes | Description |
|-------|----------|----------|-------------|
| **GPUWorkload** | Platform | `Workload`, `GPUResource`, `NodeSelector`, `Toleration` | GPU-enabled workload |
| **PrivilegedDaemon** | Platform | `Daemon`, `HostNetwork`, `HostPID`, `SecurityContext` | Privileged system daemon |
| **EdgeCompute** | Platform | `Workload`, `NodeSelector`, `Toleration`, `ResourceLimits` | Edge computing workload |
| **KubernetesOperator** | Platform | `Workload`, `RBAC`, `ServiceAccount`, `WebhookConfig` | Kubernetes operator pattern |

## Advanced Composite Traits

Complex, multi-level composite traits (depth 2-3).

| Trait | Category | Composes | Description | Depth |
|-------|----------|----------|-------------|-------|
| **FullStackApplication** | Operational | `WebService`, `Database`, `CacheLayer`, `ObservableService` | Complete application stack | 2 |
| **EnterpriseAPI** | Operational | `SecureGateway`, `CompliantService`, `ObservableService` | Enterprise-grade API | 2 |
| **DataPlatform** | Resource | `DataLake`, `DataPipeline`, `MonitoredDatabase` | Complete data platform | 2 |
| **CloudNativeApp** | Operational | `MicroService`, `ResilientService`, `ObservableService` | Cloud-native application | 3 |
| **RegulatedFinancialService** | Contractual | `CompliantService`, `SecureWorkload`, `HighAvailabilityService` | Financial services compliance | 3 |

## Usage Examples

### Simple Composite Trait

```cue
// Using a WebService composite trait
frontend: {
    traits.#WebService
    webservice: {
        replicas: 3
        containers: main: {
            image: {repository: "myapp", tag: "v1.0"}
        }
        expose: {
            port: 80
            targetPort: 8080
        }
    }
}
```

### Nested Composite Trait

```cue
// Using a CloudNativeApp (depth 3 composite)
myApp: {
    traits.#CloudNativeApp
    cloudnative: {
        microservice: {
            // MicroService configuration
        }
        resilient: {
            // ResilientService configuration
        }
        observable: {
            // ObservableService configuration
        }
    }
}
```

## Composition Rules

When creating composite traits:

1. **Maximum Depth**: Cannot exceed 3 levels of composition
2. **Circular Dependencies**: No trait can compose itself (directly or indirectly)
3. **Category Alignment**: Composite trait category should align with primary purpose
4. **Capability Inheritance**: All capabilities from composed traits are inherited
5. **Interface Design**: Provide intuitive configuration interface hiding complexity
6. **Documentation**: Document what each composed trait contributes
7. **Validation**: Ensure composed traits are compatible

## Design Patterns

### Service Pattern

Combines workload with networking and observability:

```
WebService = Workload + Route + HealthCheck + Replicable
```

### Storage Pattern

Combines workload with persistent storage:

```
Database = Workload + Volume + Secret + BackupPolicy
```

### Resilience Pattern

Combines multiple behavioral traits:

```
ResilientService = CircuitBreaker + Retry + Timeout + Fallback
```

### Security Pattern

Combines security-related traits:

```
SecureWorkload = Workload + SecurityPolicy + SecurityContext + RBAC
```

## Benefits of Composite Traits

1. **Abstraction**: Hide complexity behind simple interfaces
2. **Reusability**: Package common patterns for reuse
3. **Consistency**: Ensure best practices are followed
4. **Productivity**: Reduce configuration boilerplate
5. **Evolution**: Update patterns centrally
6. **Validation**: Built-in compatibility checking

## Notes

- Composite traits automatically compute their required capabilities
- The `composes` field must list valid trait references
- Composition depth is validated at definition time
- Some composite traits may require specific atomic traits to be implemented first
- Platform capabilities determine which composite traits can be used
