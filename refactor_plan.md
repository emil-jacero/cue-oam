# CUE-OAM Trait Validation Implementation Plan

## Overview

Implement a trait validation system where:

- Components declare traits based on application needs
- Each Kubernetes resource transformer declares its requirements
- Providers validate components against transformer requirements at render time
- Docker Compose ignores Kubernetes-specific traits

## Architecture Summary

```shell
Component (has traits) → Provider (has transformers) → Transformer (validates requirements) → Resources
```

Key principles:

1. **Components** compose traits and provide `#atomicTraits` helper field
2. **DeploymentType** trait explicitly declares the intended Kubernetes resource type
3. **Transformers** declare required/optional traits for each Kubernetes resource
4. **Validation** happens at render time with clear error messages

## Implementation Steps

### Step 1: Create DeploymentType Atomic Trait

**File:** `catalog/traits/core/v2alpha2/workload/deploymenttype.cue`

```cue
package workload

import (
    core "jacero.io/oam/core/v2alpha2"
)

// DeploymentType - Specifies the deployment pattern for the workload
#DeploymentType: core.#Trait & {
    #metadata: #traits: DeploymentType: core.#TraitMetaAtomic & {
        #kind:       "DeploymentType"
        description: "Specifies the deployment pattern for the workload"
        domain:      "workload"
        scope: ["component"]
        // MUST be OpenAPIv3 compliant
        schema: deploymentType: #DeploymentTypeSchema
    }

    deploymentType: #DeploymentTypeSchema & {
        type: #DeploymentTypes
        
        // Type-specific configuration
        if type == "Job" {
            completions?: uint | *1
            parallelism?: uint | *1
            backoffLimit?: uint | *6
            ttlSecondsAfterFinished?: uint
        }
        
        if type == "CronJob" {
            schedule!: string  // Required for CronJob (e.g., "0 2 * * *")
            successfulJobsHistoryLimit?: uint | *3
            failedJobsHistoryLimit?: uint | *1
            startingDeadlineSeconds?: uint
            concurrencyPolicy?: "Allow" | "Forbid" | "Replace" | *"Allow"
        }
        
        if type == "StatefulSet" {
            serviceName?: string  // Governing service name
            podManagementPolicy?: "OrderedReady" | "Parallel" | *"OrderedReady"
            updateStrategy?: {
                type: "RollingUpdate" | "OnDelete" | *"RollingUpdate"
                if type == "RollingUpdate" {
                    partition?: int | *0
                }
            }
        }
    }
}

#DeploymentTypeSchema: {
    type: #DeploymentTypes

    // Type-specific configuration
    // Job
    completions?: uint | *1
    parallelism?: uint | *1
    backoffLimit?: uint | *6
    ttlSecondsAfterFinished?: uint

    // CronJob
    schedule?: string  // Required for CronJob (e.g., "0 2 * * *")
    successfulJobsHistoryLimit?: uint | *3
    failedJobsHistoryLimit?: uint | *1
    startingDeadlineSeconds?: uint
    concurrencyPolicy?: "Allow" | "Forbid" | "Replace" | *"Allow"

    // StatefulSet
    serviceName?: string  // Governing service name
    podManagementPolicy?: "OrderedReady" | "Parallel" | *"OrderedReady"
    updateStrategy?: {
        type: "RollingUpdate" | "OnDelete" | *"RollingUpdate"
        if type == "RollingUpdate" {
            partition?: int | *0
        }
    }
}

#DeploymentTypes: string | *"Deployment" | "StatefulSet" | "DaemonSet" | "Job" | "CronJob" | "Pod"

#DeploymentTypeMeta: #DeploymentType.#metadata.#traits.DeploymentType

// Self-register this trait in the central registry
core.#TraitRegistry: [...#DeploymentType]
```

### Step 2: Update Component to Include #atomicTraits Helper

**File:** `core/v2alpha2/component.cue`

Add the `#atomicTraits` computed field to the existing #Component definition:

```cue
import "list"

#Component: {
    #apiVersion: "core.oam.dev/v2alpha2"
    #kind:       "Component"
    #metadata: {
        #id:          #NameType
        name:         #NameType | *#id
        labels?:      #LabelsType
        annotations?: #AnnotationsType

        // Helper: Extract ALL atomic traits (recursively traverses composites)
        #atomicTraits: [...string]
        #atomicTraits: {
            // Collect all atomic capabilities
            let allCapabilities = [
                for traitName, traitMeta in #traits {
                    // Atomic traits contribute themselves
                    if traitMeta.type == "atomic" {
                        traitMeta.#fullyQualifiedName
                    }
                    // Composite traits: collect #fullyQualifiedName from composed traits
                    if traitMeta.type == "composite" && traitMeta.composes != _|_ {
                        for composedTrait in traitMeta.composes {
                            composedTrait.#fullyQualifiedName
                        }
                    }
                }
            ]

            // Deduplicate and sort
            let set = {for cap in allCapabilities {(cap): _}}
            list.SortStrings([for k, _ in set {k}])
        }
    }

    #Trait  // Components inherit from #Trait

    // Add fields from all traits applied to this component
    for _, t in #metadata.#traits {
        t.schema
    }
}
```

### Step 3: Create Central Trait Registry

**File:** `core/v2alpha2/trait_registry.cue`

```cue
package v2alpha2

// Central trait registry - traits self-register here
#TraitRegistry: [...#Trait]

// Helper to resolve trait schema by name from registry
#ResolveTraitSchema: {
    traitName: string

    // Find trait in registry by combinedVersion
    let matchingTraits = [
        for trait in #TraitRegistry
        if trait.#metadata.#traits != _|_ {
            for _, traitMeta in trait.#metadata.#traits
            if traitMeta.#fullyQualifiedName == traitName {
                traitMeta.schema
            }
        }
    ]

    schema: {
        if len(matchingTraits) > 0 {
            matchingTraits[0]
        }
    }
}
```

### Step 4: Enhance Existing Transformer Interface

**File:** `providers/kubernetes/transformer.cue`

```cue
package kubernetes

import (
    core "jacero.io/oam/core/v2alpha2"
    "list"
    "strings"
)

// Enhanced transformer structure for Kubernetes resources
#Transformer: {
    // Resource type this transformer creates (replaces 'accepts')
    creates: string

    // Required OAM traits for this transformer to work
    required: [...string]

    // Optional OAM traits
    optional?: [...string]

    // Auto-generated defaults from optional trait schemas
    defaults: {
        // Resolve schemas from optional traits only
        for traitName in (optional | []) {
            (core.#ResolveTraitSchema & {traitName: traitName}).schema
        }

        // Allow transformer-specific additional defaults
        ...
    }

    // Validation rules (e.g., deploymentType must match)
    validates?: {
        deploymentType?: string
        [string]: _
    }

    // Transform function
    transform: {
        component: #Component
        context:   core.#ProviderContext
        output:    [..._]  // Kubernetes resources
    }
}

// Helper function to validate component against transformer
#ValidateTransformer: {
    component:    #Component
    transformer:  #Transformer

    let componentTraits = component.#metadata.#atomicTraits

    // Check required traits
    missingRequired: [
        for req in transformer.required
        if !list.Contains(componentTraits, req) {req}
    ]

    // Check validation rules
    validationErrors: [...string]
    if transformer.validates != _|_ {
        if transformer.validates.deploymentType != _|_ {
            if component.deploymentType.type != transformer.validates.deploymentType {
                validationErrors: [...validationErrors,
                    "DeploymentType mismatch: expected \(transformer.validates.deploymentType), got \(component.deploymentType.type)"
                ]
            }
        }
    }

    valid: len(missingRequired) == 0 && len(validationErrors) == 0

    if !valid {
        error: """
            Component '\(component.#metadata.name)' cannot use transformer '\(transformer.creates)':
            \(if len(missingRequired) > 0 {"Missing required traits: " + strings.Join(missingRequired, ", ")})
            \(if len(validationErrors) > 0 {strings.Join(validationErrors, "\n")})
            """
    }
}
```

### Step 4: Implement Kubernetes Resource Transformers

**File:** `providers/kubernetes/transformer_k8s_deployment.cue`

```cue
package kubernetes

import (
    core "jacero.io/oam/core/v2alpha2"
    trait "jacero.io/oam/catalog/traits/core/v2alpha2"
    schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

#DeploymentTransformer: #Transformer & {
    creates: "k8s.io/api/apps/v1.Deployment"
    
    required: [
        "core.oam.dev/v2alpha2.ContainerSet",
        "core.oam.dev/v2alpha2.DeploymentType",
    ]
    
    optional: [
        "core.oam.dev/v2alpha2.UpdateStrategy",
        "core.oam.dev/v2alpha2.RestartPolicy",
        "core.oam.dev/v2alpha2.Replicas",
        "core.oam.dev/v2alpha2.HealthCheck",
    ]
    
    validates: {
        deploymentType: "Deployment"
    }
    
    defaults: {
        // Auto-generated from required/optional trait schemas
        // ContainerSet, DeploymentType, UpdateStrategy, RestartPolicy, Replicas schemas merged

        // Additional transformer-specific defaults
        updateStrategy: {
            rollingUpdate: {
                maxSurge: int | *1      // Deployment-specific tuning
                maxUnavailable: int | *0 // More conservative than default
            }
        }
    }
    
    transform: {
        component: #Component
        context:   core.#ProviderContext
        
        // Extract traits with CUE defaults
        let containerSet = component.containerSet
        let deploymentType = component.deploymentType
        let updateStrategy = component.updateStrategy | *defaults.updateStrategy
        let replicas = component.replica | *defaults.replicas
        let restartPolicy = component.restartPolicy | *defaults.restartPolicy
        
        output: [
            schema.#Deployment & {
                metadata: #GenerateMetadata & {
                    _input: {
                        name:         component.#metadata.name
                        traitMeta:    component.#metadata
                        context:      context
                        resourceType: "deployment"
                    }
                }
                spec: {
                    replicas: replicas
                    
                    strategy: {
                        type: updateStrategy.type
                        if updateStrategy.type == "RollingUpdate" {
                            rollingUpdate: updateStrategy.rollingUpdate
                        }
                    }
                    
                    selector: matchLabels: {
                        "app.kubernetes.io/name":     component.#metadata.name
                        "app.kubernetes.io/instance": context.metadata.application.name
                    }
                    
                    template: {
                        metadata: labels: {
                            "app.kubernetes.io/name":     component.#metadata.name
                            "app.kubernetes.io/instance": context.metadata.application.name
                        }
                        spec: {
                            restartPolicy: restartPolicy
                            
                            containers: [
                                for name, container in containerSet.containers {
                                    {
                                        name: container.name
                                        image: "\(container.image.repository):\(container.image.tag)"
                                        
                                        if container.ports != _|_ {
                                            ports: [
                                                for port in container.ports {
                                                    containerPort: port.targetPort
                                                    if port.name != _|_ {name: port.name}
                                                    if port.protocol != _|_ {protocol: port.protocol}
                                                },
                                            ]
                                        }
                                        
                                        if container.env != _|_ {
                                            env: container.env
                                        }
                                        
                                        if container.resources != _|_ {
                                            resources: container.resources
                                        }
                                    }
                                },
                            ]
                        }
                    }
                }
            },
        ]
    }
}
```

**File:** `providers/kubernetes/transformer_k8s_statefulset.cue`

```cue
package kubernetes

import (
    core "jacero.io/oam/core/v2alpha2"
    schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

#StatefulSetTransformer: #Transformer & {
    creates: "k8s.io/api/apps/v1.StatefulSet"
    
    required: [
        "core.oam.dev/v2alpha2.ContainerSet",
        "core.oam.dev/v2alpha2.DeploymentType",
        "core.oam.dev/v2alpha2.Volume",  // StatefulSet needs persistent storage
    ]
    
    optional: [
        "core.oam.dev/v2alpha2.UpdateStrategy",
        "core.oam.dev/v2alpha2.RestartPolicy",
        "core.oam.dev/v2alpha2.Replicas",
    ]
    
    validates: {
        deploymentType: "StatefulSet"
    }
    
    defaults: {
        // Auto-generated from required/optional trait schemas
        // ContainerSet, DeploymentType, Volume, UpdateStrategy, RestartPolicy, Replicas schemas merged

        // Additional transformer-specific defaults
        deploymentType: {
            serviceName: string | *"headless"  // StatefulSet-specific default
        }
        updateStrategy: {
            rollingUpdate: {
                partition: int | *0  // StatefulSet-specific strategy
            }
        }
    }
    
    transform: {
        component: #Component
        context:   core.#ProviderContext
        
        // Extract traits with CUE defaults
        let updateStrategy = component.updateStrategy | *defaults.updateStrategy
        let replicas = component.replica.count | *defaults.replicas
        let restartPolicy = component.restartPolicy | *defaults.restartPolicy
        let serviceName = component.deploymentType.serviceName | *defaults.serviceName

        // Implementation creates StatefulSet with volumeClaimTemplates from component.volumes
        output: [
            schema.#StatefulSet & {
                // ... StatefulSet specific implementation
            },
        ]
    }
}
```

### Step 5: Update Kubernetes Provider

**File:** `providers/kubernetes/provider.cue`

```cue
package kubernetes

import (
    core "jacero.io/oam/core/v2alpha2"
    "list"
)

#ProviderKubernetes: core.#Provider & {
    #metadata: {
        name:        "Kubernetes"
        description: "Provider that renders resources for Kubernetes"
        minVersion:  "v1.31.0"
    }
    
    // Resource transformers with requirements
    transformers: {
        "k8s.io/api/apps/v1.Deployment":     #DeploymentTransformer
        "k8s.io/api/apps/v1.StatefulSet":    #StatefulSetTransformer
        "k8s.io/api/apps/v1.DaemonSet":      #DaemonSetTransformer
        "k8s.io/api/batch/v1.Job":           #JobTransformer
        "k8s.io/api/batch/v1.CronJob":       #CronJobTransformer
        "k8s.io/api/core/v1.ConfigMap":      #ConfigMapTransformer
        "k8s.io/api/core/v1.Secret":         #SecretTransformer
        "k8s.io/api/core/v1.Service":        #ServiceTransformer
    }
    
    render: {
        app: core.#Application
        
        output: {
            apiVersion: "v1"
            kind:       "List"
            metadata: {
                name:      app.#metadata.name
                namespace: app.#metadata.namespace
            }
            items: [
                for compName, comp in app.components {
                    // Find matching transformer based on DeploymentType
                    let match = #FindMatchingTransformer & {
                        component:    comp
                        transformers: transformers
                    }
                    
                    if match.error != _|_ {
                        error(match.error)
                    }
                    
                    // Transform component to resources
                    for resource in match.transformer.transform & {
                        component: comp
                        context: core.#ProviderContext & {
                            name:      app.#metadata.name
                            namespace: app.#metadata.namespace
                            metadata: {
                                application: {
                                    id:        app.#metadata.#id
                                    name:      app.#metadata.name
                                    namespace: app.#metadata.namespace
                                    version:   app.#metadata.version
                                    if app.#metadata.labels != _|_ {
                                        labels: app.#metadata.labels
                                    }
                                    if app.#metadata.annotations != _|_ {
                                        annotations: app.#metadata.annotations
                                    }
                                }
                                component: {
                                    id:   comp.#metadata.#id
                                    name: comp.#metadata.name
                                    if comp.#metadata.labels != _|_ {
                                        labels: comp.#metadata.labels
                                    }
                                    if comp.#metadata.annotations != _|_ {
                                        annotations: comp.#metadata.annotations
                                    }
                                }
                            }
                        }
                    }.output {
                        resource
                    }
                },
            ]
        }
    }
}

// Helper to find transformer based on deployment type
#FindMatchingTransformer: {
    component:    #Component
    transformers: [string]: #ResourceTransformer
    
    transformer?: #ResourceTransformer
    error?:       string
    
    // Get deployment type from component
    let deploymentType = component.deploymentType.type | *_|_
    
    if deploymentType == _|_ {
        error: """
            Component '\(component.#metadata.name)' missing DeploymentType trait.
            
            Add the DeploymentType trait to specify the Kubernetes resource:
            \(component.#metadata.name): #Component & {
                #DeploymentType
                deploymentType: type: "Deployment"  // or StatefulSet, Job, etc.
                // ... rest of component
            }
            """
    }
    
    if deploymentType != _|_ {
        // Find transformer for this deployment type
        let matches = [
            for name, t in transformers 
            if t.validates.deploymentType == deploymentType {
                name: t
            }
        ]
        
        if len(matches) == 0 {
            error: "No transformer found for deployment type: \(deploymentType)"
        }
        
        if len(matches) > 0 {
            transformer: matches[0]
            
            // Validate component has required traits
            let validation = #ValidateTransformer & {
                component:    component
                transformer:  transformer
            }
            
            if !validation.valid {
                error: validation.error
            }
        }
    }
}
```

### Step 6: Create Composite Traits

**File:** `catalog/traits/core/v2alpha2/workload/composites.cue`

```cue
package workload

import (
    core "jacero.io/oam/core/v2alpha2"
)

// Universal workload that works on both Kubernetes and Docker Compose
#UniversalWorkload: core.#Trait & {
    #metadata: #traits: UniversalWorkload: core.#TraitMetaComposite & {
        #kind:       "UniversalWorkload"
        description: "Universal workload that works across platforms"
        domain:      "workload"
        scope: ["component"]
        composes: [
            #ContainerSetMeta,
            #DeploymentTypeMeta,    // Kubernetes uses, Compose ignores
            #UpdateStrategyMeta,    // Kubernetes uses, Compose ignores
            #RestartPolicyMeta,     // Both use
            #ReplicaMeta,          // Kubernetes uses
        ]
        // MUST be OpenAPIv3 compliant
        schema: workload: #WorkloadSchema
    }
    
    // Sensible defaults
    workload: #WorkloadSchema & {
        deploymentType: type: *"Deployment"
        updateStrategy: type: *"RollingUpdate"
        restartPolicy: *"Always"
        replica: count: *1
    }
}

#WorkloadSchema: {
    deploymentType: type: *"Deployment"
    updateStrategy: type: *"RollingUpdate"
    restartPolicy: *"Always"
    replica: count: *1
}

#UniversalWorkloadMeta: #UniversalWorkload.#metadata.#traits.UniversalWorkload

// Kubernetes-specific deployment
#KubernetesDeployment: core.#Trait & {
    #metadata: #traits: KubernetesDeployment: core.#TraitMetaComposite & {
        #kind:       "KubernetesDeployment"
        description: "Kubernetes Deployment workload"
        domain:      "workload"
        scope: ["component"]
        composes: [
            #ContainerSetMeta,
            #DeploymentTypeMeta,
            #UpdateStrategyMeta,
            #RestartPolicyMeta,
            #ReplicaMeta,
        ]
        // MUST be OpenAPIv3 compliant
        schema: deployment: #DeploymentSchema
    }
    deployment: #DeploymentSchema
}

#DeploymentSchema: {
    deploymentType: type: "Deployment"  // Fixed
    // The rest of the config fields
}

#KubernetesDeploymentMeta: #KubernetesDeployment.#metadata.#traits.KubernetesDeployment

// Kubernetes StatefulSet
#KubernetesStatefulSet: core.#Trait & {
    #metadata: #traits: KubernetesStatefulSet: core.#TraitMetaComposite & {
        #kind:       "KubernetesStatefulSet"
        description: "Kubernetes StatefulSet workload"
        domain:      "workload"
        scope: ["component"]
        composes: [
            #ContainerSetMeta,
            #DeploymentTypeMeta,
            #VolumeMeta,          // Required for StatefulSet
            #UpdateStrategyMeta,
            #RestartPolicyMeta,
            #ReplicaMeta,
        ]
        // MUST be OpenAPIv3 compliant
        schema: statefulSet: #StatefulSetSchema
    }
    statefulSet: #StatefulSetSchema
}

#StatefulSetSchema: {
    deploymentType: type: "StatefulSet"  // Fixed
    // The rest of the config fields
}

#KubernetesStatefulSetMeta: #KubernetesStatefulSet.#metadata.#traits.KubernetesStatefulSet
```

### Step 7: Example Application

**File:** `examples/validated-application.cue`

```cue
package examples

import (
    core "jacero.io/oam/core/v2alpha2"
    trait "jacero.io/oam/catalog/traits/core/v2alpha2"
    k8s "jacero.io/oam/providers/kubernetes"
    compose "jacero.io/oam/providers/compose"
)

// Example application with proper validation
validatedApp: core.#Application & {
    #metadata: {
        name:      "validated-app"
        namespace: "production"
        version:   "1.0.0"
    }
    
    components: {
        // Using composite trait - automatically valid
        frontend: {
            trait.#UniversalWorkload
            
            containerSet: containers: main: {
                name: "nginx"
                image: {
                    repository: "nginx"
                    tag:        "1.24"
                }
                ports: [{
                    name:       "http"
                    targetPort: 80
                    protocol:   "TCP"
                }]
            }
            
            // UniversalWorkload provides default deployment type
            // deploymentType: type: "Deployment" (default from composite)
        }
        
        // Explicit atomic traits
        database: {
            trait.#ContainerSet
            trait.#DeploymentType
            trait.#Volume
            trait.#UpdateStrategy
            
            deploymentType: type: "StatefulSet"  // Explicit
            
            containerSet: containers: main: {
                name: "postgres"
                image: {
                    repository: "postgres"
                    tag:        "15"
                }
            }
            
            volumes: data: {
                type: "volume"
                size: "20Gi"
                mountPath: "/var/lib/postgresql/data"
            }
            
            updateStrategy: {
                type: "RollingUpdate"
                rollingUpdate: partition: 0
            }
        }
        
        // Scheduled job
        backup: {
            trait.#ContainerSet
            trait.#DeploymentType
            
            deploymentType: {
                type: "CronJob"
                schedule: "0 2 * * *"
                successfulJobsHistoryLimit: 1
            }
            
            containerSet: containers: main: {
                name: "backup"
                image: {
                    repository: "backup-tool"
                    tag:        "v1.0"
                }
            }
        }
    }
}

// Render for Kubernetes - validates all requirements
k8sManifests: k8s.#ProviderKubernetes.render & {
    app: validatedApp
}
// ✓ frontend: Creates Deployment (has ContainerSet + DeploymentType)
// ✓ database: Creates StatefulSet (has ContainerSet + DeploymentType + Volume)
// ✓ backup: Creates CronJob (has ContainerSet + DeploymentType with schedule)

// Render for Docker Compose - ignores DeploymentType
composeFile: compose.#ProviderCompose.render & {
    app: validatedApp
}
// ✓ All components become services (only needs ContainerSet)
```

### Step 8: Test Error Cases

**File:** `examples/validation-errors.cue`

```cue
package examples

import (
    core "jacero.io/oam/core/v2alpha2"
    trait "jacero.io/oam/catalog/traits/core/v2alpha2"
    k8s "jacero.io/oam/providers/kubernetes"
)

// Test case 1: Missing DeploymentType
missingTypeApp: core.#Application & {
    components: {
        web: {
            trait.#ContainerSet  // Only this
            
            containerSet: containers: main: {
                image: {repository: "nginx", tag: "1.24"}
            }
        }
    }
}

k8sError1: k8s.#ProviderKubernetes.render & {
    app: missingTypeApp
}
// Error: Component 'web' missing DeploymentType trait.

// Test case 2: StatefulSet without Volume
invalidStatefulApp: core.#Application & {
    components: {
        db: {
            trait.#ContainerSet
            trait.#DeploymentType
            // Missing Volume!
            
            deploymentType: type: "StatefulSet"
            containerSet: {...}
        }
    }
}

k8sError2: k8s.#ProviderKubernetes.render & {
    app: invalidStatefulApp
}
// Error: Component 'db' cannot use transformer 'k8s.io/api/apps/v1.StatefulSet':
// Missing required traits: core.oam.dev/v2alpha2.Volume

// Test case 3: CronJob without schedule
invalidCronApp: core.#Application & {
    components: {
        job: {
            trait.#ContainerSet
            trait.#DeploymentType
            
            deploymentType: {
                type: "CronJob"
                // Missing schedule!
            }
            containerSet: {...}
        }
    }
}

k8sError3: k8s.#ProviderKubernetes.render & {
    app: invalidCronApp
}
// Error: DeploymentType.CronJob requires schedule field
```

## Checklist

1. [x] Central trait registry with self-registration pattern
   - [x] Commit: `git commit -m "Add central trait registry with #ResolveTraitSchema helper"`
2. [x] Rename #combinedVersion to #fullyQualifiedName and simplify capabilities
   - [x] Remove requiredCapability from atomic traits (use #fullyQualifiedName)
   - [x] Remove requiredCapabilities from composite traits (collect from composes)
   - [x] Update #atomicTraits helper to use #fullyQualifiedName
   - [x] Commit: `git commit -m "Rename #combinedVersion to #fullyQualifiedName and simplify capabilities"`
3. [ ] DeploymentType trait created and self-registers in registry
   - [ ] Commit: `git commit -m "Add DeploymentType atomic trait with OpenAPIv3 schema"`
4. [ ] Component #atomicTraits helper computes correctly
   - [ ] Commit: `git commit -m "Add #atomicTraits helper to Component for recursive trait resolution"`
5. [ ] Enhanced #Transformer interface with auto-generated defaults
   - [ ] Commit: `git commit -m "Enhance #Transformer interface with registry-based defaults"`
6. [ ] Each Kubernetes resource has a transformer with requirements
   - [ ] Commit: `git commit -m "Add Kubernetes resource transformers with validation"`
7. [ ] Provider validates components against transformer requirements
   - [ ] Commit: `git commit -m "Update Kubernetes provider with component validation"`
8. [ ] Clear error messages for missing traits
   - [ ] Commit: `git commit -m "Add detailed validation error messages"`
9. [ ] Composite traits include DeploymentType with schema field
   - [ ] Commit: `git commit -m "Update composite traits to use schema field"`
10. [ ] Docker Compose ignores DeploymentType
    - [ ] Commit: `git commit -m "Verify Docker Compose ignores Kubernetes-specific traits"`
11. [ ] Example applications render correctly
    - [ ] Commit: `git commit -m "Add validated example applications"`
12. [ ] Final integration test
    - [ ] Commit: `git commit -m "Complete trait validation implementation 🚀"`

## Key Files to Modify/Create

1. `core/v2alpha2/trait_registry.cue` - Central trait registry with self-registration
2. `catalog/traits/core/v2alpha2/workload/deploymenttype.cue` - New trait that self-registers
3. `core/v2alpha2/component.cue` - Add #atomicTraits helper and rename provides→schema
4. `providers/kubernetes/transformer.cue` - Enhanced #Transformer with registry-based defaults
5. `providers/kubernetes/transformer_k8s_*.cue` - One per K8s resource type with auto-defaults
6. `providers/kubernetes/provider.cue` - Update render logic with validation
7. `catalog/traits/core/v2alpha2/workload/composites.cue` - Update to use schema field

## Success Criteria

- Components explicitly declare deployment type via DeploymentType trait
- All traits use `schema` field with OpenAPIv3 compliance
- Transformer defaults auto-generated from trait schemas
- Kubernetes provider validates requirements based on deployment type
- Clear error messages when requirements aren't met
- Docker Compose successfully ignores Kubernetes-specific traits
- Composite traits provide good defaults while allowing overrides
- Git commits track each implementation step
