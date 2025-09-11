# Kubernetes Atomic Traits

This directory contains a comprehensive collection of atomic traits for Kubernetes resources, organized by functional domain. These traits provide OAM v2alpha2 definitions for all major Kubernetes resource types.

## Directory Structure

```
catalog/traits/kubernetes/
├── workload/           # Pod-based workload controllers
├── networking/         # Network services and policies
├── storage/           # Storage resources and classes  
├── configuration/     # Configuration and secrets management
├── scaling/           # Horizontal and vertical scaling
├── security/          # RBAC and security policies
├── observability/     # Monitoring and metrics collection
└── kubernetes.cue     # Main index file importing all traits
```

## Trait Categories

### Workload Traits (`workload/`)

Pod-based workload controllers for different application patterns:

- **`Deployment`** - Stateless workloads with rolling updates
- **`StatefulSet`** - Stateful workloads with stable network identities and persistent storage
- **`DaemonSet`** - Ensures pods run on all (or some) nodes
- **`Job`** - Batch or one-time tasks
- **`CronJob`** - Scheduled batch jobs

All workload traits include:
- Full pod specification with containers, volumes, security contexts
- Resource requests and limits
- Health probes (liveness, readiness, startup)  
- Affinity and anti-affinity rules
- Tolerations and node selection
- Update strategies

### Networking Traits (`networking/`)

Network services and traffic policies:

- **`Service`** - Expose applications as network services (ClusterIP, NodePort, LoadBalancer)
- **`Ingress`** - HTTP/HTTPS access from outside the cluster with routing rules
- **`NetworkPolicy`** - Fine-grained network traffic control for pods

### Storage Traits (`storage/`)

Persistent storage management:

- **`PersistentVolumeClaim`** - Request persistent storage with access modes and size
- **`StorageClass`** - Define storage classes with provisioners and parameters

### Configuration Traits (`configuration/`)

Configuration and secrets management:

- **`ConfigMap`** - Store non-sensitive configuration data as key-value pairs
- **`Secret`** - Store sensitive data with base64 encoding and immutability options

### Scaling Traits (`scaling/`)

Automatic scaling based on metrics:

- **`HorizontalPodAutoscaler`** - Scale pods based on CPU, memory, or custom metrics
- **`VerticalPodAutoscaler`** - Adjust resource requests based on actual usage

### Security Traits (`security/`)

RBAC and identity management:

- **`ServiceAccount`** - Provide identity for processes running in pods
- **`Role`** - Define permissions within a namespace
- **`RoleBinding`** - Grant role permissions to users/groups/service accounts
- **`ClusterRole`** - Define cluster-wide permissions
- **`ClusterRoleBinding`** - Grant cluster-wide role permissions

### Observability Traits (`observability/`)

Monitoring and metrics collection (Prometheus Operator):

- **`ServiceMonitor`** - Configure Prometheus to scrape metrics from services
- **`PodMonitor`** - Configure Prometheus to scrape metrics directly from pods

## Usage

### Import Individual Traits

```cue
import (
    "jacero.io/oam/catalog/traits/kubernetes/workload"
    "jacero.io/oam/catalog/traits/kubernetes/networking"
)

// Use specific traits
myDeployment: workload.#Deployment & {
    provides: deployment: {
        metadata: name: "my-app"
        spec: {
            replicas: 3
            template: spec: containers: [{
                name: "app"
                image: "nginx:1.21"
            }]
        }
    }
}

myService: networking.#Service & {
    provides: service: {
        metadata: name: "my-app-service"  
        spec: {
            selector: app: "my-app"
            ports: [{
                port: 80
                targetPort: 8080
            }]
        }
    }
}
```

### Import All Kubernetes Traits

```cue
import k8s "jacero.io/oam/catalog/traits/kubernetes"

// All traits available as k8s.TraitName
myApp: k8s.Deployment & { /* ... */ }
myService: k8s.Service & { /* ... */ }
```

## Trait Design Principles

### Atomic Traits

All traits in this collection are **atomic traits** with the following characteristics:

- `type: "atomic"` - No composition with other traits
- `requiredCapabilities` - Specify exact Kubernetes API resources needed
- Complete resource specification - Full Kubernetes resource schema
- Provider agnostic - Can be implemented by any Kubernetes provider

### Categories

Traits are categorized based on their primary function:

- **`structural`** - Define the fundamental structure of applications (workloads, networking)
- **`operational`** - Control runtime behavior (scaling, jobs, monitoring)  
- **`resource`** - Manage cluster resources (storage, configuration, security)

### Scope

All traits have `scope: ["component"]` indicating they apply to individual components rather than scopes.

## Provider Integration

These atomic traits are designed to work with the Kubernetes provider (`providers/kubernetes/provider.cue`), which handles:

- Resource transformation from OAM traits to Kubernetes manifests
- Label and annotation management
- Namespace and naming conventions
- Cross-resource relationships

## Validation

All traits include comprehensive CUE validation:

- Required vs optional fields
- Enum constraints for string values  
- Numeric ranges for ports, replicas, etc.
- Structural validation for nested objects

## Compatibility

- **Kubernetes**: v1.31.0+
- **OAM**: v2alpha2
- **CUE**: v0.14.0+

## Examples

See the `examples/` directory (if present) for complete application examples using these traits, or refer to the main repository examples that demonstrate trait composition and usage patterns.