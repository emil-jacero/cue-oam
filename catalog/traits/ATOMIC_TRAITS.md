# Example Atomic Traits Catalog

This document provides a comprehensive list of all atomic traits in the CUE-OAM system. Atomic traits are the fundamental building blocks that cannot be decomposed further and provide specific, focused functionality.

## Overview

Atomic traits are characterized by:

- `type: "atomic"` in their metadata
- No `composes` field (they don't compose other traits)
- Manually specified `requiredCapabilities` when needed
- Single, focused responsibility

## Operational Traits

Traits that manage runtime behavior and workload execution.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **Workload** | Core container workload with deployment options (Deployment/StatefulSet/DaemonSet) | Platform container runtime |
| **Job** | One-time task execution that runs to completion | `batch/v1.Job` |
| **CronJob** | Scheduled recurring task execution | `batch/v1.CronJob` |
| **Replicable** | Adds replica count and scaling configuration | `apps/v1.Deployment` or `apps/v1.StatefulSet` |
| **Scalable** | Manual scaling configuration with min/max replicas | `apps/v1.Deployment` |
| **Autoscaler** | Automatic scaling based on CPU/memory metrics (HPA) | `autoscaling/v2.HorizontalPodAutoscaler` |
| **VerticalAutoscaler** | Automatic resource request/limit adjustments (VPA) | `autoscaling.k8s.io/v1.VerticalPodAutoscaler` |
| **RollingUpdate** | Rolling update strategy configuration | `apps/v1.Deployment` |
| **BlueGreenDeploy** | Blue-green deployment strategy | Custom controller or Flagger |
| **CanaryDeploy** | Canary deployment with traffic splitting | Istio or Flagger |
| **Sidecar** | Additional container injection into pods | Pod spec modification |
| **InitContainer** | Initialization container configuration | Pod spec modification |
| **HealthCheck** | Liveness and readiness probe configuration | Container probe support |
| **Lifecycle** | Container lifecycle hooks (postStart/preStop) | Container lifecycle support |

## Structural Traits

Traits that define organization, relationships, and connectivity.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **Route** | Basic service exposure and routing | `core/v1.Service` |
| **Ingress** | HTTP/HTTPS ingress routing rules | `networking.k8s.io/v1.Ingress` |
| **LoadBalancer** | Load balancer service configuration | `core/v1.Service` type LoadBalancer |
| **NetworkPolicy** | Network access control and segmentation | `networking.k8s.io/v1.NetworkPolicy` |
| **ServiceDiscovery** | Service registration and discovery | `core/v1.Service` |
| **Gateway** | API gateway configuration | Gateway API or Istio Gateway |
| **ServiceMesh** | Service mesh sidecar injection | Istio/Linkerd |
| **DNSPolicy** | DNS resolution configuration | Pod DNS policy |
| **NetworkIsolationScope** | Network isolation boundaries | `networking.k8s.io/v1.NetworkPolicy` |
| **AffinityRules** | Pod placement constraints and preferences | Pod affinity/anti-affinity |
| **TopologySpread** | Even pod distribution across zones/nodes | `topologySpreadConstraints` |
| **ServiceAccount** | Kubernetes service account binding | `core/v1.ServiceAccount` |

## Behavioral Traits

Traits that implement logic, patterns, and behavioral aspects.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **CircuitBreaker** | Fault tolerance with circuit breaking | Service mesh or library |
| **Retry** | Configurable retry logic for failures | Service mesh or application |
| **Timeout** | Request and operation timeout settings | Service mesh or application |
| **RateLimiter** | Rate limiting for API protection | Service mesh or ingress |
| **Bulkhead** | Resource isolation and throttling | Service mesh or application |
| **Cache** | Caching behavior and configuration | Redis/Memcached or in-memory |
| **Queue** | Message queue integration | RabbitMQ/Kafka/SQS |
| **EventTrigger** | Event-driven execution triggers | KEDA or Knative Eventing |
| **Fallback** | Fallback behavior on failure | Application or service mesh |
| **Throttle** | Request throttling configuration | Ingress or service mesh |
| **Debounce** | Event debouncing configuration | Application level |
| **BatchProcessor** | Batch processing configuration | Application level |

## Resource Traits

Traits that manage state, data, and system resources.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **Volume** | Persistent or temporary storage volumes | `core/v1.PersistentVolumeClaim` |
| **Secret** | Secret data management (passwords, keys, certificates) | `core/v1.Secret` |
| **Config** | Configuration data via ConfigMaps | `core/v1.ConfigMap` |
| **Certificate** | TLS certificate management | `cert-manager.io/v1.Certificate` |
| **BackupPolicy** | Data backup scheduling and retention | Velero or similar |
| **Snapshot** | Volume snapshot creation and management | `snapshot.storage.k8s.io` |
| **License** | Software license key management | `core/v1.Secret` |
| **Migration** | Database migration execution | Job or init container |
| **Schema** | Database schema definitions | ConfigMap or CRD |
| **ObjectStorage** | S3-compatible object storage | Cloud provider or MinIO |
| **KeyVault** | External secret management integration | External Secrets Operator |
| **ResourceLimits** | CPU/Memory resource constraints | Container resources |
| **StorageClass** | Storage class selection | `storage.k8s.io/v1.StorageClass` |
| **DataReplication** | Data replication configuration | StatefulSet or operator |

## Contractual Traits

Traits that enforce constraints, policies, and compliance requirements.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **SecurityPolicy** | Security constraints and policies | PodSecurityPolicy/Standards |
| **CompliancePolicy** | Regulatory compliance rules (HIPAA, PCI-DSS) | OPA or Kyverno |
| **ResourceQuota** | Resource usage limits and quotas | `core/v1.ResourceQuota` |
| **PodDisruptionBudget** | Availability guarantees during disruptions | `policy/v1.PodDisruptionBudget` |
| **SLA** | Service level agreement definitions | Custom metrics/monitoring |
| **RBAC** | Role-based access control | `rbac.authorization.k8s.io/v1` |
| **Audit** | Audit logging configuration | Audit policy or sidecar |
| **CostControl** | Budget and cost constraints | Cloud provider APIs |
| **LimitRange** | Min/max resource constraints | `core/v1.LimitRange` |
| **PriorityClass** | Pod scheduling priority | `scheduling.k8s.io/v1.PriorityClass` |
| **SecurityContext** | Security context for containers/pods | Pod/Container security context |
| **NetworkSegmentation** | Network segmentation policies | NetworkPolicy |
| **DataGovernance** | Data governance and retention policies | Custom controllers |

## Observability Traits

Traits focused on monitoring, logging, and observability.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **Metrics** | Metrics exposure and collection | Prometheus or similar |
| **Logging** | Log collection and forwarding | Fluentd/Fluent Bit |
| **Tracing** | Distributed tracing configuration | OpenTelemetry/Jaeger |
| **Profiling** | Application profiling configuration | Profiling tools |
| **HealthEndpoint** | Health check endpoint exposure | HTTP endpoint |
| **Dashboard** | Monitoring dashboard configuration | Grafana or similar |
| **Alerts** | Alert rule configuration | Prometheus AlertManager |
| **Events** | Kubernetes event configuration | Event API |

## Platform-Specific Traits

Traits that integrate with specific platform features.

| Trait | Description | Required Capabilities |
|-------|-------------|----------------------|
| **GPUResource** | GPU resource allocation | GPU device plugin |
| **NodeSelector** | Node selection constraints | Node labels |
| **Toleration** | Pod toleration configuration | Node taints |
| **HostNetwork** | Host network mode | Host network access |
| **HostPID** | Host PID namespace | Host PID access |
| **HostIPC** | Host IPC namespace | Host IPC access |
| **HostPath** | Host path volume mounting | Host filesystem access |
| **RuntimeClass** | Container runtime selection | `node.k8s.io/v1.RuntimeClass` |

## Usage Example

```cue
package example

import traits "jacero.io/oam/catalog/traits/standard"

// Using an atomic trait
myComponent: {
    traits.#Workload
    workload: {
        containers: main: {
            image: {repository: "nginx", tag: "1.24"}
        }
    }
}
```

## Trait Implementation Guidelines

When implementing atomic traits:

1. **Single Responsibility**: Each atomic trait should have one clear purpose
2. **Minimal Dependencies**: List only essential required capabilities
3. **Clear Interface**: Define a clear `provides` field structure
4. **Validation**: Include CUE constraints for input validation
5. **Documentation**: Provide clear descriptions and examples
6. **Category Assignment**: Assign to exactly one category
7. **Scope Definition**: Specify where the trait can be applied (component/scope)

## Notes

- All atomic traits must have `type: "atomic"` in their metadata
- Atomic traits form the foundation for composite traits
- Platform capabilities determine which traits can be used
- Some traits may require specific operators or controllers to be installed
