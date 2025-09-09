# CUE-OAM: Open Application Model Implementation in CUE

[![CUE Version](https://img.shields.io/badge/CUE-v0.14.0-blue)](https://cuelang.org)
[![OAM Version](https://img.shields.io/badge/OAM-v2alpha2-green)](https://oam.dev)

A modern implementation of the Open Application Model (OAM) specification using the CUE configuration language. This project provides a type-safe, composable system for defining cloud-native applications with provider-agnostic abstractions.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Trait Catalog](#trait-catalog)
- [Providers](#providers)
- [Examples](#examples)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview

CUE-OAM implements a hierarchical, trait-based system where **"everything is a trait"**. This unified architecture provides consistency, type safety, and powerful composition capabilities for defining cloud-native applications. The system supports multiple providers (Kubernetes, Docker Compose) enabling true platform portability.

### Core Philosophy

- **Unified Architecture**: All OAM types inherit from a common `#Trait` base
- **Composition Over Inheritance**: Complex behaviors built from atomic traits
- **Type Safety**: Leverages CUE's constraint system for validation
- **Provider Abstraction**: Clean separation between definitions and implementations
- **Self-Documenting**: Structure reveals behavior and relationships

## Features

✅ **Trait-Based Composition**: Atomic and composite traits with validation  
✅ **Five-Domain System**: Operational, Structural, Behavioral, Resource, Contractual  
✅ **Provider System**: Pluggable providers for Kubernetes, Docker Compose  
✅ **Hierarchical Metadata**: Application → Component → Resource inheritance  
✅ **Capability Verification**: Automatic validation of core vs modifier traits  
✅ **Type Safety**: Built-in validation with CUE constraints  
✅ **Composition Depth Control**: Maximum 3-level nesting with circular dependency detection  
✅ **Rich Metadata**: Self-documenting traits with capability requirements  
🚧 **Scope System**: Cross-cutting concerns management (in progress)  
🚧 **Policy Framework**: Operational rules and behaviors (planned)  
📅 **Bundle System**: Multi-application deployment packages (planned)

## Architecture

### Type Hierarchy

```shell
Bundle [planned]
  └── Application(s)
        ├── Component(s)
        │     └── Trait(s) [Atomic or Composite]
        ├── Scope(s) [in progress]
        └── Policy(s) [planned]
```

### Directory Structure

```shell
cue-oam/
├── core/v2alpha2/        # Core OAM v2alpha2 definitions
│   ├── trait.cue         # Trait system with composition
│   ├── component.cue     # Component definitions
│   ├── application.cue   # Application structure
│   ├── scope.cue        # Scope definitions
│   └── provider.cue     # Provider interfaces
├── catalog/             # Standard trait implementations
│   └── traits/
│       └── standard/
│           ├── workload.cue    # Workload trait
│           ├── database.cue    # Database trait
│           ├── volume.cue      # Volume trait
│           └── schema/         # Common schemas
├── providers/           # Provider implementations
│   ├── kubernetes/      # Kubernetes provider
│   └── compose/        # Docker Compose provider
├── examples/           # Example applications
└── design/            # Design documentation
    └── proposals/     # Architecture proposals
```

## Quick Start

### Prerequisites

- [CUE](https://cuelang.org/docs/install/) v0.14.0 or later
- Basic understanding of CUE language
- (Optional) Kubernetes cluster for deployment

### Installation

```bash
# Clone the repository
git clone https://github.com/emiljacero/cue-oam.git
cd cue-oam

# Validate CUE modules
cue mod tidy
```

### Basic Usage

1. **Define an Application**

    ```cue
    package myapp

    import (
        core "jacero.io/oam/core/v2alpha2"
        trait "jacero.io/oam/catalog/traits/standard"
        k8s "jacero.io/oam/providers/kubernetes"
    )

    app: core.#Application & {
        #metadata: {
            name: "my-app"
            namespace: "default"
            version: "1.0.0"
            labels: {
                team: "platform"
                env: "production"
            }
        }
        
        components: {
            web: {
                #metadata: {
                    labels: {tier: "frontend"}
                }
                
                trait.#ContainerSet
                trait.#Expose
                
                containerSet: {
                    containers: main: {
                        name: "nginx"
                        image: {
                            repository: "nginx"
                            tag: "1.24"
                        }
                        ports: [{
                            name: "http"
                            targetPort: 80
                            protocol: "TCP"
                        }]
                    }
                }
                
                expose: {
                    type: "ClusterIP"
                    ports: [{
                        name: "http"
                        targetPort: 80
                        exposedPort: 80
                    }]
                }
            }
        }
    }
    ```

2. **Export to Kubernetes**

    ```cue
    // Render Kubernetes manifests
    k8sManifests: k8s.#ProviderKubernetes.render & {
        app: app
    }
    ```

    ```bash
    # Export rendered Kubernetes resources
    cue eval myapp.cue -e "k8sManifests.output" --out yaml

    # Apply to Kubernetes
    cue eval myapp.cue -e "k8sManifests.output" --out yaml | kubectl apply -f -
    ```

## Core Concepts

### Traits

Traits are the fundamental building blocks in CUE-OAM. Every trait belongs to one of five domains:

#### Trait Domains

| Domain | Purpose | Examples |
|--------|---------|----------|
| **Operational** | Runtime behavior and workload management | Workload, Task, Scaling |
| **Structural** | Organization and relationships | Network, ServiceMesh |
| **Behavioral** | Logic and patterns | Retry, CircuitBreaker |
| **Resource** | State and data management | Volume, Config, Database |
| **Contractual** | Constraints and policies | Policy, SLA, Security |

#### Trait Types

- **Atomic Traits**: Basic building blocks with no composition
- **Composite Traits**: Built from other traits (max depth: 3)

```cue
// Atomic trait example
#Volume: #Trait & {
    #metadata: #traits: Volume: {
        type: "atomic"
        domain: "resource"
        scope: ["component"]
        provides: {volume: {...}}
    }
}

// Composite trait example
#Database: #Trait & {
    #metadata: #traits: Database: {
        type: "composite"
        domain: "resource"
        composes: [#Workload, #Volume]
        // requiredCapabilities auto-computed
    }
}
```

### Components

Components combine multiple traits to form deployable units:

```cue
webServer: #Component & {
    #Workload     // Container capabilities
    #Volume       // Storage capabilities
    #Config       // Configuration management
    
    workload: containers: main: {
        image: {repository: "nginx", tag: "latest"}
    }
    volumes: static: {size: "10Gi"}
}
```

### Applications

Applications orchestrate multiple components:

```cue
ecommerce: #Application & {
    #metadata: {
        name: "ecommerce-platform"
        version: "2.0.0"
    }
    
    components: {
        frontend: {...}  // Web UI
        api: {...}       // REST API
        database: {...}  // PostgreSQL
        cache: {...}     // Redis
    }
    
    scopes: {
        network: {...}   // Network isolation
        monitoring: {...} // Observability
    }
}
```

## Trait Catalog

### Standard Traits Available

| Trait | Category | Type | Description |
|-------|----------|------|-------------|
| `#Workload` | Operational | Atomic | Container workload with deployment options |
| `#Database` | Resource | Composite | Database with persistent storage |
| `#Volume` | Resource | Atomic | Persistent or temporary storage |
| `#Secret` | Resource | Atomic | Secret management |
| `#Config` | Resource | Atomic | Configuration via ConfigMap |
| `#NetworkIsolationScope` | Structural | Atomic | Network policy management |

### Creating Custom Traits

```cue
package custom

import core "jacero.io/oam/core/v2alpha2"

#CustomCache: core.#Trait & {
    #metadata: #traits: CustomCache: {
        type: "composite"
        domain: "resource"
        scope: ["component"]
        composes: [#Workload, #Volume]
        description: "Custom caching layer"
    }
    
    // Implementation details...
}
```

## Providers

Providers translate OAM definitions to target platforms with intelligent capability verification and hierarchical metadata management.

### Provider Features

#### Capability Verification

Providers distinguish between:

- **Core Traits**: Create primary resources (must be supported, errors if missing)
- **Modifier Traits**: Enhance existing resources (safely ignored if unsupported)

#### Hierarchical Metadata

Automatic metadata inheritance from Application → Component → Resource:

```cue
app: #Application & {
    #metadata: {
        labels: {team: "platform"}  // Applied to ALL resources
    }
    components: {
        web: {
            #metadata: {
                labels: {tier: "frontend"}  // Merged with app labels
            }
        }
    }
}
```

### Kubernetes Provider

Full support for Kubernetes resources with automatic transformation:

- Deployments, StatefulSets, DaemonSets
- Services and Ingress
- ConfigMaps and Secrets
- PersistentVolumes
- NetworkPolicies
- RBAC resources

```cue
import k8s "jacero.io/oam/providers/kubernetes"

// Render application for Kubernetes
k8sManifests: k8s.#ProviderKubernetes.render & {
    app: myApp
}

// Resources will have:
// - Standard Kubernetes labels (app.kubernetes.io/*)
// - OAM metadata (oam.dev/*)
// - Hierarchical labels/annotations from app & components
```

### Docker Compose Provider

Basic support for Docker Compose format (in development):

```cue
import compose "jacero.io/oam/providers/compose"

// Render application for Docker Compose
composeFile: compose.#ProviderCompose.render & {
    app: myApp
}
```

### Creating Custom Providers

Providers implement a pluggable interface:

```cue
#CustomProvider: core.#Provider & {
    #metadata: {
        name: "CustomProvider"
        capabilities: [...]      // Supported traits
        coreTraits: [...]       // Must support these
        modifierTraits: [...]   // Can safely ignore these
    }
    
    transformers: {
        "core.oam.dev/v2alpha2.ContainerSet": #MyTransformer
    }
    
    render: {
        app: core.#Application
        output: {...}  // Provider-specific output
    }
}
```

## Examples

### Simple Web Application

```cue
webApp: #Application & {
    components: web: {
        #Workload
        workload: {
            replicas: 3
            containers: main: {
                image: {repository: "nginx", tag: "1.24"}
                ports: [{containerPort: 80}]
                resources: {
                    requests: {cpu: "100m", memory: "128Mi"}
                    limits: {cpu: "500m", memory: "512Mi"}
                }
            }
        }
    }
}
```

### Database with Volume

```cue
database: #Component & {
    #Database
    database: {
        databaseType: "postgres"
        version: "15"
        storage: {size: "20Gi"}
        credentials: {
            username: "admin"
            secretRef: "db-secret"
        }
    }
}
```

### Full examples available in `/examples/` directory

## Development

### Commands

```bash
# Validate CUE files
cue vet <file.cue>

# Format CUE files
cue fmt <file.cue>

# Evaluate definitions
cue eval <file.cue>

# Export to JSON/YAML
cue export <file.cue> --out json
cue export <file.cue> --out yaml

# Test examples
cue export examples/example-application.cue
```

### Testing

```bash
# Run validation tests
cue vet ./...

# Export and validate all examples
for f in examples/*.cue; do
    echo "Testing $f"
    cue export "$f" > /dev/null || exit 1
done
```

## Roadmap

### ✅ Completed

- Core v2alpha2 API
- Trait composition system with domains
- Standard trait catalog
- Kubernetes provider with full metadata support
- Hierarchical metadata inheritance system
- Provider capability verification (core vs modifier traits)
- Basic and advanced examples

### 🚧 In Progress

- Scope system implementation
- Database traits enhancement
- Docker Compose provider completion

### 📅 Planned

- [ ] Policy framework
- [ ] Bundle system
- [ ] CLI tooling (`oam` command)
- [ ] Workflow/pipeline support
- [ ] OSCAL compliance integration
- [ ] Helm chart generation
- [ ] Terraform provider
- [ ] Advanced networking traits
- [ ] Service mesh integration

## Design Principles

1. **Everything is a Trait**: Unified architecture for consistency
2. **Composition Over Inheritance**: Build complex behaviors from simple traits
3. **Type Safety First**: Leverage CUE's constraint system
4. **Provider Agnostic**: Write once, deploy anywhere
5. **Self-Documenting**: Structure reveals intent
6. **Fail Fast**: Validation at definition time

## Known Issues

- Docker Compose provider incomplete (basic support only)
- Some trait implementations pending (Workflow, Pipeline)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Areas for Contribution

- Additional trait implementations
- Provider enhancements
- Documentation improvements
- Example applications
- Test coverage
- CLI tooling

## References

- [Open Application Model Specification](https://oam.dev)
- [CUE Language Documentation](https://cuelang.org/docs/)
- [Design Proposals](./design/proposals/)
- [Trait Architecture Rules](./design/trait-rules.md)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The OAM community for the specification
- The CUE team for the powerful configuration language
- Contributors and early adopters

---

**Note**: This project is under active development. APIs may change. For production use, please pin to specific versions.
