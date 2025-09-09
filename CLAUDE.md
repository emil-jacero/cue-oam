# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an implementation of the Open Application Model (OAM) v2alpha specification using CUE language. The project provides a hierarchical, composable system for defining cloud-native applications with six primary definition types: Traits, Components, Scopes, Applications, Bundles, and Policies.

## Key Commands

### CUE Operations

```bash
# Validate CUE files
cue vet <file.cue>

# Evaluate and export CUE files
cue eval <file.cue>
cue export <file.cue> --out json
cue export <file.cue> --out yaml

# Format CUE files
cue fmt <file.cue>

# Export application configuration
cue export example.cue
cue export exanples/example-application.cue
```

## Architecture Overview

### Core Type Hierarchy

```shell
Bundle [planned]
  └── Application(s)
        ├── Component(s)
        │     └── Trait(s)
        ├── Scope(s) [planned]
        └── Policy(s) [planned]
```

### Module Structure

- **Module Name**: `jacero.io/oam`
- **CUE Version**: v0.14.0
- **Dependencies**: Kubernetes schemas from `cue.dev/x/k8s.io@v0`

### Directory Layout

- `/core/v2alpha2/` - Core OAM v2alpha2 definitions
  - `trait.cue` - Trait definition with composition support
  - `component.cue` - Component definition
  - `application.cue` - Application definition
  - `scope.cue` - Scope definition
  - `provider.cue` - Provider interfaces
  
- `/catalog/traits/` - Standard trait implementations
  - `/standard/schema/` - Common schemas (container, network, storage, data)
  
- `/providers/` - Provider implementations
  - `/kubernetes/` - Kubernetes provider
  - `/compose/` - Docker Compose provider
  
- `/oam-schema/` - OAM v1beta1 legacy schemas and components
  - `/oam/oam-v1beta1/` - Complete v1beta1 trait/component library
  
- `/design/` - Design documentation
  - `/proposals/` - Design proposals for traits, scopes, policies

### Key Concepts

#### Traits

- **Atomic Traits**: Basic building blocks with no composition
- **Composite Traits**: Built from other traits (max depth: 3)
- Traits provide capabilities via the `provides` field
- Categories: operational, structural, behavioral, resource, contractual
- Scope: Can apply to components or scopes

#### Components

- Logical units combining multiple traits
- Represent deployable entities (web servers, databases, APIs)
- Have unique identifiers within applications

#### Applications

- Collections of components working together
- Define complete application topology
- Include scopes for shared resources

## Development Guidelines

### When Working with Traits

1. Check trait composition depth (max 3 levels)
2. Validate circular dependencies
3. Composite traits auto-compute `requiredCapabilities`
4. Use `#metadata.#traits` for trait metadata

### When Working with Applications

1. Components are defined in `components: [string]: #Component`
2. Scopes are defined in `scopes: [string]: #Scope`
3. Use proper namespacing and labels in `#metadata`

### Type System

- All types use `#` prefix for definitions (e.g., `#Trait`, `#Component`)
- Metadata follows `#ComponentMeta` structure
- Use CUE's constraint system for validation
- Leverage composition and inheritance for code reuse

### Provider Integration

- Providers translate OAM definitions to target platforms
- Current providers: Kubernetes, Docker Compose
- Provider interfaces defined in `/providers/*/provider.cue`
