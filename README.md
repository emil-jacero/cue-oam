# OAM v3alpha1 Definition Types

This document describes the core definition types in the Open Application Model (OAM) v3alpha1 specification. These types work together to create a hierarchical, composable system for defining cloud-native applications.

## Overview

The OAM model provides six primary definition types that build upon each other:

```shell
Bundle
  └── Application(s)
        ├── Component(s)
        │     └── Trait(s)
        ├── Scope(s)
        └── Policy(s) [planned]
```

## Definition Types

### 🧩 #Trait

**Purpose**: Reusable building blocks that encapsulate specific functionality or behavior.

**Description**: Traits are the atomic units of functionality in OAM. They define specific capabilities like workloads, volumes, databases, configurations, or networking rules. Traits can inherit from other traits, enabling composition and reuse.

**Key Features**:

- Can extend other traits via inheritance
- Self-contained configuration units
- Reusable across multiple components
- Can provide metadata about their capabilities

**Example Use Cases**:

- `#Workload`: Defines containers and their runtime configuration
- `#Volume`: Manages persistent storage
- `#Database`: Extends Workload to provide database-specific configuration
- `#Secret`: Manages sensitive configuration data
- `#Config`: Handles application configuration

```cue
#Database: #Workload & {
    #metadata: {
        #traits: Database: {
            extends: "Workload"
            provides: ["database", "persistence"]
            description: "PostgreSQL database with persistent storage"
        }
    }
    database: {
        databaseType: "postgres"
        version: "15"
    }
}
```

### 📦 #Component

**Purpose**: Logical units that combine multiple traits to form deployable entities.

**Description**: Components are collections of traits that work together to provide a complete piece of functionality. A component might represent a web server, a database, an API service, or any other deployable unit of your application.

**Key Features**:

- Combines multiple traits
- Represents a deployable unit
- Has a unique identifier within an application
- Can apply labels and annotations

**Example**:

```cue
web: #Component & {
    #Workload  // Adds container capabilities
    #Volume    // Adds storage capabilities
    
    containers: main: {
        image: "nginx:latest"
        replicas: 3
    }
    volumes: {
        static: {type: "volume", size: "10Gi"}
    }
}
```

### 🔗 #Scope

**Purpose**: Defines logical or physical boundaries for groups of components that share common runtime characteristics.

**Description**: Scopes are application boundaries that group components with shared properties, dependencies, or environments. They define how components relate to each other at runtime and what resources or constraints they share. Scopes act as a mechanism for platform operators to inject operational behaviors and group-level resources without requiring developers to change their components.

**Key Features**:

- Creates boundaries (network, health, security, or resource)
- Groups components that share runtime characteristics
- Enables platform-level control without modifying components
- Can overlap - components can belong to multiple scopes
- Provides shared configuration and resources
- Defines failure domains and blast radius

**Types of Boundaries**:

- **Network Scopes**: Define which components can communicate (e.g., VPC, subnet, service mesh)
- **Health Scopes**: Define failure domains and health aggregation boundaries
- **Resource Scopes**: Share common resources like storage backends or databases
- **Security Scopes**: Apply common security policies, RBAC, or compliance rules
- **Execution Scopes**: Define deployment targets (regions, clusters, namespaces)

**Example Use Cases**:

```cue
// Network Scope - Components share a network boundary
networkScope: #Scope & {
    #metadata: {
        name: "internal-network"
        labels: {
            type: "network"
            subnet: "10.0.1.0/24"
        }
    }
    // Components in this scope can communicate with each other
    children: [components.web, components.api, components.db]
}

// Health Scope - Define a failure domain
healthScope: #Scope & {
    #metadata: {
        name: "payment-service-health"
        labels: {
            type: "health"
            sla: "99.99"
        }
    }
    // If any component fails, the entire scope is considered unhealthy
    children: [components.paymentAPI, components.paymentDB, components.paymentCache]
}

// Execution Scope - Deploy to specific environment
regionScope: #Scope & {
    #metadata: {
        name: "us-west-2"
        labels: {
            type: "execution"
            region: "us-west-2"
            environment: "production"
        }
    }
    // All components deploy to this region
    children: [components.web, components.api]
}
```

**Important Characteristics**:

- **Overlapping**: A component can exist in multiple scopes (e.g., both a network scope and a health scope)
- **Platform-controlled**: Scopes are typically defined by platform teams, not application developers
- **Runtime-focused**: Scopes affect runtime behavior, not build-time configuration
- **Hierarchical**: Scopes can potentially contain other scopes for complex topologies

### 🚀 #Application

**Purpose**: Represents a complete application with all its components, scopes, and policies.

**Description**: An Application is a collection of components that work together to deliver functionality. It defines the complete topology of your application including all services, their relationships, and operational policies.

**Key Features**:

- Contains multiple components
- Defines component relationships and dependencies
- Includes scopes for shared resources
- Will support policies for operational rules (planned)
- Can be deployed as a single unit

**Example**:

```cue
myApp: #Application & {
    #metadata: {
        name: "e-commerce-platform"
        labels: {
            version: "2.0"
            team: "platform"
        }
    }
    components: {
        frontend: {/* ... */}
        api: {/* ... */}
        database: {/* ... */}
        cache: {/* ... */}
    }
    scopes: {
        network: {/* ... */}
        monitoring: {/* ... */}
    }
    // policies: {} // Coming soon
}
```

### 📚 #Bundle

**Purpose**: Groups multiple related applications together for distribution and deployment.

**Description**: Bundles are the highest-level organizational unit, allowing you to package and distribute multiple applications as a cohesive unit. This is useful for complex systems that span multiple applications or for creating reusable application templates.

**Key Features**:

- Contains multiple applications
- Facilitates distribution and sharing
- Enables versioning of application sets
- Useful for multi-tenant or multi-environment deployments

**Example Use Cases**:

- A complete microservices platform with multiple applications
- Environment-specific application sets (dev, staging, prod)
- Reusable application templates for different customers
- Multi-region deployment packages

```cue
platformBundle: #Bundle & {
    #metadata: {
        name: "acme-platform"
        labels: {
            release: "2024.1"
            customer: "acme-corp"
        }
    }
    applications: {
        mainApp: {/* ... */}
        adminPortal: {/* ... */}
        analyticsStack: {/* ... */}
        monitoringTools: {/* ... */}
    }
}
```

### 📋 #Policy [Planned]

**Purpose**: Define operational rules and behaviors for applications.

**Description**: Policies will enforce specific rules and behaviors at the application level. While not yet implemented in the current schema, they are planned for future releases.

**Planned Use Cases**:

- `apply-once`: Ensure components are only deployed once
- `rolling-update`: Define update strategies
- `auto-scaling`: Automatic scaling rules
- `backup`: Data backup policies
- `security`: Security and compliance rules

## Relationships

The definition types form a clear hierarchy:

1. **Traits** are composed into **Components**
2. **Components** are grouped by **Scopes** and organized into **Applications**
3. **Applications** are packaged into **Bundles**
4. **Policies** (when implemented) will govern **Application** behavior

## Best Practices

### Trait Design

- Keep traits focused on a single concern
- Use trait inheritance for specialization (e.g., Database extends Workload)
- Document what capabilities each trait provides

### Component Composition

- Combine only compatible traits
- Use meaningful component names that reflect their purpose
- Avoid overly complex components - split if necessary

### Application Structure

- Group related components that need to be deployed together
- Use scopes for shared resources and cross-cutting concerns
- Plan for policies even if not yet implemented

### Bundle Organization

- Bundle applications that share a common lifecycle
- Use bundles for versioning related applications together
- Consider bundles for multi-environment deployments

## Example: Complete Application

```cue
// Each application is independently versioned
webStore: #Application & {
    #metadata: {
        name: "web-store"
        labels: {
            version: "2.1.0"
            description: "E-commerce web store application"
        }
    }
    components: {
        frontend: {
            #Workload
            #Volume
            containers: main: {
                image: "store-ui:2.1.0"  // Version-tagged images
                replicas: 3
            }
        }
        backend: {
            #Workload
            #Config
            containers: main: {
                image: "store-api:2.1.0"
                replicas: 2
            }
        }
        database: {
            #Database
            #Volume
            database: {
                databaseType: "postgres"
                version: "15"
            }
        }
    }
    scopes: {
        network: {
            children: [
                components.frontend,
                components.backend,
                components.database
            ]
        }
    }
}


// Deploy with: oam bundle deploy web-store-platform:1.0.0
```

This hierarchical model provides flexibility, reusability, and clear separation of concerns while maintaining type safety through CUE's constraint system. The versioning and distribution capabilities make OAM packages as shareable and reusable as Helm Charts.
