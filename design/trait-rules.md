# CUE-OAM Trait Design Rules

## Executive Summary

CUE-OAM traits are the fundamental building blocks for defining cloud-native applications. They follow a unified architecture where **everything is a trait**, organized into eight fundamental categories. Traits can be either **atomic** (fundamental building blocks) or **composite** (built from other traits), and they operate at different architectural levels (component, application, scope, bundle, promise).

The trait system emphasizes:

- **Type safety** through CUE's constraint system
- **Self-documentation** through structure
- **Maximum reusability** across different levels
- **Clear separation of concerns** through categorization
- **Composition over inheritance** for flexibility

## The 15 Rules of Trait Design

### 1. **Trait Categorization Rule**

Every trait MUST belong to exactly ONE of eight fundamental categories:

- `operational` - Runtime behavior (Workload, Task, Scaling)
- `structural` - Organization & relationships
- `behavioral` - Logic & patterns (Retry, CircuitBreaker)
- `resource` - State & data (Volume, Config, Database)
- `contractual` - Constraints & policies (Policy, SLA)
- `security` - Protection & control (RBAC, NetworkPolicy, Certificates)
- `observability` - Monitoring & understanding (ServiceMonitor, Logging, Tracing)
- `integration` - Connectivity & communication (ServiceMesh, MessageQueue, APIGateway)

### 2. **Metadata Requirements Rule**

Every trait MUST define these metadata fields:

- `description` (recommended) - Human-readable description
- `type` (required) -  The type of this trait (`atomic`, `composite`)
- `category` (required) - The trait category
- `scope` (required) - Where trait can be applied
- `composes` (composite only) - List of composed traits
- `requiredCapabilities` (optional) - Platform capabilities needed
- `provides` (required) - Fields this trait adds to a component

### 3. **Atomic vs Composite Rule**

- **Atomic traits**: `type: "atomic"`, no `composes` field, manually specify `requiredCapabilities`, depth = 0
- **Composite traits**: `type: "composite"`, have `composes` field, MUST NOT specify `requiredCapabilities` (auto-computed)
- Type field is required and must match the presence of `composes` field
- Composition depth: atomic traits are level 0, composites can go up to level 3
- Circular dependencies are prohibited and automatically detected

### 4. **Scope Assignment Rule**

Traits must explicitly declare supported scopes based on where their concern applies:

- `component` - Where actual work happens
- `scope` - Where environments are managed

### 5. **Single Responsibility Rule**

Each atomic trait should have ONE clear responsibility. Use composition to combine multiple concerns rather than creating complex multi-purpose traits.

### 6. **Self-Documentation Rule**

Traits must be self-documenting through their structure:

- Presence of `composes` indicates composite trait
- Clear `provides` field showing added functionality
- Descriptive field names indicating purpose

### 7. **Provider Compatibility Rule**

Traits must declare platform requirements clearly in the `requiredCapabilities` field, listing specific capabilities or resources needed for the trait to function.

### 8. **Field Provisioning Rule**

The `provides` field must accurately declare what fields the trait adds to enable proper validation and discovery.

### 9. **Naming Convention Rule**

- Trait names: PascalCase with "Trait" as suffix (e.g., `#WebServiceTrait`)
- Trait object names: PascalCase (e.g., `#WebService`)
- Field names: camelCase (e.g., `workload`)
- Category values: lowercase (e.g., `"operational"`)

### 10. **Type Safety Rule**

Leverage CUE's type system for validation:

- Use constraints for ranges (`uint & >=1 & <=65535`)
- Provide defaults (`uint | *1`)
- Apply string limits (`string & strings.MaxRunes(253)`)

### 11. **Extensibility Rule**

Design traits to be extensible:

- Use open structs (`...`) where appropriate
- Make fields optional with `?`
- Provide sensible defaults with `*`

## Quick Reference

### Trait Structure Template

```cue
#MyTrait: #Trait & {
    #metadata: #traits: MyTrait: #TraitObject & {
        description: "What this trait does"
        type: "atomic|composite"  // Required field
        domain: "operational|structural|behavioral|resource|contractual|security|observability|integration"
        scope: ["component", "scope"]
        composes: [  // Only for composite traits (type must be "composite")
            #OtherTrait.#metadata.#traits.OtherTrait
        ]
        requiredCapabilities: [  // Only for atomic traits
            "core.oam.dev/v2alpha1.Capability"
        ]
        provides: {
            fieldName: #MyTrait.fieldName
        }
    }
    
    // Trait-specific fields
    fieldName: {
        // Implementation
    }
}
```

### Category Decision Matrix

| Category | Primary Focus | Typical Scope | Examples |
|----------|--------------|---------------|----------|
| Operational | How things execute | component | Workload, Task, Scaling |
| Structural | How things organize | scope | Network, ServiceMesh, Topology |
| Behavioral | How things react | component | Retry, CircuitBreaker, Throttle |
| Resource | What things have/need | component | Volume, Config, Database |
| Contractual | What things guarantee | all levels | Policy, SLA |
| Security | How things are protected | all levels | RBAC, NetworkPolicy, Certificates |
| Observability | How things are monitored | all levels | ServiceMonitor, Logging, Tracing |
| Integration | How things connect | all levels | ServiceMesh, MessageQueue, APIGateway |

### Scope Selection Guide

| Level | Use When | Example Traits |
|-------|----------|----------------|
| component | Trait controls individual component behavior | Workload, Volume, Container |
| application | Trait manages component relationships | ServiceDiscovery, LoadBalancer |
| scope | Trait applies to environment/namespace | NetworkPolicy, ResourceQuota |
| bundle | Trait controls distribution/packaging | VersionPolicy, DistributionRules |
| promise | Trait defines templates/defaults | SLA, DefaultLimits |

## Best Practices

1. **Start Simple**: Begin with atomic traits, compose them later
2. **Think Reusability**: Design traits that work across multiple contexts
3. **Document Intent**: Use clear descriptions and field names
4. **Validate Early**: Use CUE's type system to catch errors at design time
5. **Follow Patterns**: Use existing traits as templates for new ones
6. **Test Composition**: Verify composite traits work as expected
7. **Consider Evolution**: Design with future extensions in mind

## Common Pitfalls to Avoid

- ❌ Creating overly complex atomic traits (violates Single Responsibility)
- ❌ Mixing categories within a single trait
- ❌ Forgetting to declare `provides` accurately
- ❌ Manually specifying `requiredCapabilities` in composite traits
- ❌ Creating composition hierarchies deeper than level 3 (depth > 3)
- ❌ Mismatching `type` field with presence of `composes` field
- ❌ Creating circular dependencies in trait composition
- ❌ Using incorrect scope assignments
- ❌ Ignoring type safety constraints
- ❌ Breaking backward compatibility without documentation
