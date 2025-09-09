# Proposed Kubernetes Atomic Traits Catalog

## Overview

This document outlines all proposed atomic traits specifically for Kubernetes resources in the CUE-OAM system, organized by priority. These traits are based on core Kubernetes manifests and provide direct mapping to native Kubernetes API resources.

## Priority Classification

- **P0 (Critical)**: Core Kubernetes workload and resource traits required for production deployments
- **P1 (High)**: Important Kubernetes features for enhanced functionality and production readiness
- **P2 (Medium)**: Additional Kubernetes features that improve developer experience
- **P3 (Low)**: Specialized Kubernetes features for specific use cases

---

## P0 - Critical Priority Traits (12 traits)

### Must Have - Core Kubernetes resources required for production workloads

| Trait | Category | Description | Justification | Kubernetes Resource |
|-------|----------|-------------|---------------|-------------------|
| **Deployment** | operational | Kubernetes Deployment for stateless workloads with rolling updates | Essential for running stateless applications with declarative updates and scaling | `apps/v1.Deployment` |
| **StatefulSet** | operational | Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage | Required for databases, message queues, and other stateful services needing stable identities | `apps/v1.StatefulSet` |
| **DaemonSet** | operational | Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod | Essential for node-level services like monitoring agents, log collectors, and network proxies | `apps/v1.DaemonSet` |
| **Job** | operational | Kubernetes Job for running batch or one-time tasks | Fundamental for batch processing, data migrations, and initialization tasks | `batch/v1.Job` |
| **CronJob** | operational | Kubernetes CronJob for running jobs on a scheduled basis | Essential for scheduled maintenance, backups, report generation, and periodic tasks | `batch/v1.CronJob` |
| **Service** | structural | Kubernetes Service for exposing an application running on a set of Pods as a network service | Core networking primitive for service discovery and load balancing within cluster | `core/v1.Service` |
| **Ingress** | structural | Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster | Standard way to expose HTTP services externally with routing rules and TLS termination | `networking.k8s.io/v1.Ingress` |
| **ConfigMap** | resource | Kubernetes ConfigMap for storing configuration data as key-value pairs | Fundamental for externalizing configuration from container images | `core/v1.ConfigMap` |
| **Secret** | resource | Kubernetes Secret for storing sensitive configuration data | Critical for managing passwords, tokens, and certificates securely | `core/v1.Secret` |
| **PersistentVolumeClaim** | resource | Kubernetes PersistentVolumeClaim for requesting persistent storage | Essential for any stateful workload requiring data persistence | `core/v1.PersistentVolumeClaim` |
| **ServiceAccount** | structural | Kubernetes ServiceAccount provides an identity for processes that run in a Pod | Required for pod-level authentication and RBAC integration | `core/v1.ServiceAccount` |
| **NetworkPolicy** | contractual | Kubernetes NetworkPolicy for controlling network traffic to and from pods | Critical for security and implementing zero-trust networking principles | `networking.k8s.io/v1.NetworkPolicy` |

---

## P1 - High Priority Traits (15 traits)

### Should Have - Important Kubernetes features for enhanced functionality

| Trait | Category | Description | Justification | Kubernetes Resource |
|-------|----------|-------------|---------------|-------------------|
| **HorizontalPodAutoscaler** | operational | Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics | Enables dynamic scaling to handle variable load, improving cost efficiency and availability | `autoscaling/v2.HorizontalPodAutoscaler` |
| **VerticalPodAutoscaler** | operational | Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage | Optimizes resource allocation without manual tuning, reducing waste and improving performance | `autoscaling.k8s.io/v1.VerticalPodAutoscaler` |
| **PodDisruptionBudget** | contractual | Kubernetes PodDisruptionBudget maintains availability during disruptions | Critical for high-availability services during maintenance operations and cluster updates | `policy/v1.PodDisruptionBudget` |
| **Role** | contractual | Kubernetes Role contains rules that represent a set of permissions within a namespace | Essential for implementing fine-grained access control within namespaces | `rbac.authorization.k8s.io/v1.Role` |
| **RoleBinding** | structural | Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users | Required to actually apply RBAC permissions to users and service accounts | `rbac.authorization.k8s.io/v1.RoleBinding` |
| **ClusterRole** | contractual | Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level | Needed for cluster-wide permissions and cross-namespace operations | `rbac.authorization.k8s.io/v1.ClusterRole` |
| **ClusterRoleBinding** | structural | Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide | Required for cluster-wide permission assignments | `rbac.authorization.k8s.io/v1.ClusterRoleBinding` |
| **StorageClass** | resource | Kubernetes StorageClass for defining classes of storage | Enables workloads to request specific storage characteristics (SSD, replicated, etc.) | `storage.k8s.io/v1.StorageClass` |
| **PersistentVolume** | resource | Kubernetes PersistentVolume represents a piece of storage in the cluster | Provides abstraction layer for storage provisioning and management | `core/v1.PersistentVolume` |
| **ServiceMonitor** | structural | Prometheus ServiceMonitor for scraping metrics from services | Standard way to configure Prometheus to collect metrics from Kubernetes services | `monitoring.coreos.com/v1.ServiceMonitor` |
| **PodMonitor** | structural | Prometheus PodMonitor for scraping metrics directly from pods | Enables metrics collection from pods without requiring a service | `monitoring.coreos.com/v1.PodMonitor` |
| **Endpoint** | structural | Kubernetes Endpoints define the network endpoints for a service | Low-level networking primitive for service discovery and load balancing | `core/v1.Endpoints` |
| **EndpointSlice** | structural | Kubernetes EndpointSlices provide a scalable way to track network endpoints | Modern replacement for Endpoints, supports larger clusters and more efficient updates | `discovery.k8s.io/v1.EndpointSlice` |
| **ResourceQuota** | contractual | Kubernetes ResourceQuota enforces resource usage limits | Prevents resource exhaustion and enables multi-tenancy at the namespace level | `core/v1.ResourceQuota` |
| **LimitRange** | contractual | Kubernetes LimitRange sets min/max resource constraints | Prevents resource waste and ensures fair usage within namespaces | `core/v1.LimitRange` |

---

## P2 - Medium Priority Traits (18 traits)

### Nice to Have - Additional Kubernetes features that improve developer experience

| Trait | Category | Description | Justification | Kubernetes Resource |
|-------|----------|-------------|---------------|-------------------|
| **IngressClass** | structural | Kubernetes IngressClass for defining ingress controller classes | Enables multiple ingress controllers in the same cluster with different capabilities | `networking.k8s.io/v1.IngressClass` |
| **Gateway** | structural | Gateway API Gateway for advanced traffic management | Next-generation ingress with more powerful routing and traffic management capabilities | `gateway.networking.k8s.io/v1.Gateway` |
| **GatewayClass** | structural | Gateway API GatewayClass for defining gateway controller classes | Enables multiple gateway controllers with different feature sets | `gateway.networking.k8s.io/v1.GatewayClass` |
| **HTTPRoute** | behavioral | Gateway API HTTPRoute for HTTP traffic routing | Provides advanced HTTP routing capabilities beyond basic Ingress | `gateway.networking.k8s.io/v1.HTTPRoute` |
| **VolumeSnapshot** | resource | Kubernetes VolumeSnapshot for point-in-time snapshots | Enables backup and recovery scenarios for persistent volumes | `snapshot.storage.k8s.io/v1.VolumeSnapshot` |
| **VolumeSnapshotClass** | resource | Kubernetes VolumeSnapshotClass for defining snapshot provisioner classes | Allows different snapshot policies and backends | `snapshot.storage.k8s.io/v1.VolumeSnapshotClass` |
| **VolumeSnapshotContent** | resource | Kubernetes VolumeSnapshotContent represents the actual snapshot content | Low-level resource for managing snapshot lifecycle | `snapshot.storage.k8s.io/v1.VolumeSnapshotContent` |
| **PriorityClass** | contractual | Kubernetes PriorityClass defines pod scheduling priority | Ensures critical workloads get scheduled first during resource contention | `scheduling.k8s.io/v1.PriorityClass` |
| **RuntimeClass** | structural | Kubernetes RuntimeClass selects container runtime configuration | Enables use of specialized runtimes like gVisor, Kata Containers, or Firecracker | `node.k8s.io/v1.RuntimeClass` |
| **PodSecurityPolicy** | contractual | Kubernetes PodSecurityPolicy controls security-sensitive aspects of pod specification | Enforces security best practices at the cluster level (deprecated in favor of Pod Security Standards) | `policy/v1beta1.PodSecurityPolicy` |
| **ValidatingAdmissionWebhook** | contractual | Kubernetes ValidatingAdmissionWebhook for custom validation logic | Enables custom policy enforcement and validation beyond built-in controllers | `admissionregistration.k8s.io/v1.ValidatingAdmissionWebhook` |
| **MutatingAdmissionWebhook** | behavioral | Kubernetes MutatingAdmissionWebhook for custom resource modification | Allows automatic injection of sidecars, labels, and other modifications | `admissionregistration.k8s.io/v1.MutatingAdmissionWebhook` |
| **PrometheusRule** | contractual | Prometheus PrometheusRule for defining alerting and recording rules | Configures Prometheus monitoring and alerting rules declaratively | `monitoring.coreos.com/v1.PrometheusRule` |
| **Event** | structural | Kubernetes Event provides information about cluster activities | Essential for debugging and auditing cluster operations | `events.k8s.io/v1.Event` |
| **Lease** | structural | Kubernetes Lease for leader election and coordination | Enables distributed coordination and leader election patterns | `coordination.k8s.io/v1.Lease` |
| **CSIDriver** | structural | Kubernetes CSIDriver for Container Storage Interface drivers | Enables integration with external storage systems | `storage.k8s.io/v1.CSIDriver` |
| **CSINode** | structural | Kubernetes CSINode for CSI driver node information | Provides node-specific CSI driver information | `storage.k8s.io/v1.CSINode` |
| **CSIStorageCapacity** | resource | Kubernetes CSIStorageCapacity for storage capacity information | Enables topology-aware storage provisioning | `storage.k8s.io/v1.CSIStorageCapacity` |

---

## P3 - Low Priority Traits (12 traits)

### Optional - Specialized Kubernetes features for specific use cases

| Trait | Category | Description | Justification | Kubernetes Resource |
|-------|----------|-------------|---------------|-------------------|
| **Node** | structural | Kubernetes Node represents a worker machine | Low-level resource typically managed by cluster operators | `core/v1.Node` |
| **Namespace** | structural | Kubernetes Namespace provides a mechanism for isolating groups of resources | Fundamental for multi-tenancy but usually managed at higher levels | `core/v1.Namespace` |
| **PodTemplate** | structural | Kubernetes PodTemplate describes a pod that will be created | Building block for other controllers, rarely used directly | `core/v1.PodTemplate` |
| **ReplicationController** | operational | Kubernetes ReplicationController ensures a specified number of pod replicas | Legacy resource replaced by Deployment and ReplicaSet | `core/v1.ReplicationController` |
| **ReplicaSet** | operational | Kubernetes ReplicaSet maintains a stable set of replica Pods | Low-level resource typically managed by Deployment | `apps/v1.ReplicaSet` |
| **ControllerRevision** | resource | Kubernetes ControllerRevision represents a revision of a controller | Internal resource for tracking controller history | `apps/v1.ControllerRevision` |
| **HorizontalPodAutoscalerBehavior** | behavioral | Kubernetes HPA behavior configuration for fine-tuned scaling | Advanced scaling configuration for specialized use cases | Part of `autoscaling/v2.HorizontalPodAutoscaler` |
| **FlowSchema** | contractual | Kubernetes FlowSchema for API Priority and Fairness | Advanced API server configuration for request flow control | `flowcontrol.apiserver.k8s.io/v1beta3.FlowSchema` |
| **PriorityLevelConfiguration** | contractual | Kubernetes PriorityLevelConfiguration for API request priority levels | Advanced API server configuration for request prioritization | `flowcontrol.apiserver.k8s.io/v1beta3.PriorityLevelConfiguration` |
| **TokenRequest** | operational | Kubernetes TokenRequest for requesting service account tokens | Low-level security primitive for token management | `authentication.k8s.io/v1.TokenRequest` |
| **TokenReview** | behavioral | Kubernetes TokenReview for validating authentication tokens | Used by webhook authenticators for token validation | `authentication.k8s.io/v1.TokenReview` |
| **LocalSubjectAccessReview** | behavioral | Kubernetes LocalSubjectAccessReview for checking permissions | Used for authorization checks within namespaces | `authorization.k8s.io/v1.LocalSubjectAccessReview` |

---

## Summary by Domain

### Workload Traits (9 total)
- **P0**: Deployment, StatefulSet, DaemonSet, Job, CronJob
- **P3**: PodTemplate, ReplicationController, ReplicaSet, ControllerRevision

### Networking Traits (9 total)
- **P0**: Service, Ingress, NetworkPolicy
- **P1**: Endpoint, EndpointSlice
- **P2**: IngressClass, Gateway, GatewayClass, HTTPRoute

### Storage Traits (9 total)
- **P0**: PersistentVolumeClaim
- **P1**: StorageClass, PersistentVolume
- **P2**: VolumeSnapshot, VolumeSnapshotClass, VolumeSnapshotContent, CSIDriver, CSINode, CSIStorageCapacity

### Security Traits (11 total)
- **P0**: ServiceAccount
- **P1**: Role, RoleBinding, ClusterRole, ClusterRoleBinding
- **P2**: PodSecurityPolicy, ValidatingAdmissionWebhook, MutatingAdmissionWebhook
- **P3**: TokenRequest, TokenReview, LocalSubjectAccessReview

### Configuration Traits (8 total)
- **P0**: ConfigMap, Secret
- **P1**: ResourceQuota, LimitRange
- **P2**: PriorityClass, RuntimeClass, Lease, FlowSchema, PriorityLevelConfiguration

### Scaling Traits (4 total)
- **P1**: HorizontalPodAutoscaler, VerticalPodAutoscaler, PodDisruptionBudget
- **P3**: HorizontalPodAutoscalerBehavior

### Observability Traits (4 total)
- **P1**: ServiceMonitor, PodMonitor
- **P2**: PrometheusRule, Event

### Platform Traits (3 total)
- **P3**: Node, Namespace, PodTemplate

## Summary by Category

### Operational Traits (10 total)
- **P0**: Deployment, StatefulSet, DaemonSet, Job, CronJob
- **P1**: HorizontalPodAutoscaler, VerticalPodAutoscaler
- **P3**: ReplicationController, ReplicaSet, TokenRequest

### Structural Traits (17 total)
- **P0**: Service, Ingress, ServiceAccount
- **P1**: RoleBinding, ClusterRoleBinding, ServiceMonitor, PodMonitor, Endpoint, EndpointSlice
- **P2**: IngressClass, Gateway, GatewayClass, Event, Lease, CSIDriver, CSINode
- **P3**: Node, Namespace, PodTemplate

### Behavioral Traits (4 total)
- **P2**: HTTPRoute, MutatingAdmissionWebhook
- **P3**: HorizontalPodAutoscalerBehavior, TokenReview, LocalSubjectAccessReview

### Resource Traits (14 total)
- **P0**: ConfigMap, Secret, PersistentVolumeClaim
- **P1**: StorageClass, PersistentVolume
- **P2**: VolumeSnapshot, VolumeSnapshotClass, VolumeSnapshotContent, CSIStorageCapacity
- **P3**: ControllerRevision

### Contractual Traits (12 total)
- **P0**: NetworkPolicy
- **P1**: PodDisruptionBudget, Role, ClusterRole, ResourceQuota, LimitRange
- **P2**: PriorityClass, PodSecurityPolicy, ValidatingAdmissionWebhook, PrometheusRule, FlowSchema, PriorityLevelConfiguration

---

## Implementation Roadmap

### Phase 1: Core Workloads and Networking (P0 - 12 traits)
Focus on essential Kubernetes resources needed for basic application deployment.

**Priority Order:**
1. Workload traits: Deployment, StatefulSet, Job - Core application patterns
2. Networking traits: Service, Ingress - Basic connectivity
3. Configuration traits: ConfigMap, Secret - Configuration management
4. Storage traits: PersistentVolumeClaim - Data persistence
5. Security traits: ServiceAccount, NetworkPolicy - Basic security

### Phase 2: Production Readiness (P1 - 15 traits)
Add important features for production deployments and operational excellence.

**Priority Order:**
1. Scaling traits: HorizontalPodAutoscaler, PodDisruptionBudget - Availability
2. Security traits: RBAC (Role, RoleBinding, ClusterRole, ClusterRoleBinding) - Access control
3. Observability traits: ServiceMonitor, PodMonitor - Monitoring
4. Storage traits: StorageClass, PersistentVolume - Advanced storage
5. Additional workload traits: DaemonSet, CronJob - Specialized patterns

### Phase 3: Enhanced Features (P2 - 18 traits)
Implement advanced features that improve developer experience and capabilities.

**Priority Order:**
1. Gateway API traits: Gateway, GatewayClass, HTTPRoute - Advanced networking
2. Storage snapshot traits: VolumeSnapshot, VolumeSnapshotClass - Backup/recovery
3. Security enhancement traits: Admission webhooks - Policy enforcement
4. CSI traits: CSIDriver, CSINode - Storage integration

### Phase 4: Specialized Use Cases (P3 - 12 traits)
Add specialized traits for edge cases and advanced scenarios.

**Priority Order:**
1. Legacy workload traits: ReplicationController, ReplicaSet - Compatibility
2. Platform management traits: Node, Namespace - Infrastructure
3. Advanced security traits: Token management - Fine-grained security

---

## Design Principles for Kubernetes Traits

1. **Native Resource Mapping**: Each atomic trait maps directly to a Kubernetes API resource
2. **Schema Compatibility**: Traits should expose the full Kubernetes resource schema
3. **Version Awareness**: Support multiple API versions where applicable
4. **Controller Requirements**: Document any required controllers or operators
5. **Security Defaults**: Provide secure defaults aligned with Kubernetes best practices
6. **Lifecycle Management**: Consider resource dependencies and creation/deletion order
7. **Validation**: Use CUE constraints to validate Kubernetes resource specifications

---

## Usage Guidelines

### When to Use P0 (Critical)
- Basic application deployment scenarios
- Fundamental networking and storage needs
- Essential security and configuration requirements

### When to Use P1 (High)
- Production deployments requiring high availability
- Advanced security and access control
- Comprehensive monitoring and observability
- Complex storage requirements

### When to Use P2 (Medium)
- Advanced networking scenarios requiring Gateway API
- Backup and disaster recovery implementations
- Policy enforcement and compliance requirements
- Integration with external storage systems

### When to Use P3 (Low)
- Legacy system compatibility
- Low-level infrastructure management
- Specialized security requirements
- Platform administration tasks

---

## Total Count: 57 Proposed Kubernetes Atomic Traits