# TODO

## Core Implementation

- [x] Define core OAM Schemas
- [x] Create example workload (server type)
- [x] Create example component (webapp)
- [x] Create example application (code-server)
- [x] Define initial Docker Compose transformer schema
- [ ] Define a generalized ConfigMap and Secret schema

## Transformers

- [ ] **Docker Compose Transformer**
  - [ ] Complete unified transformer implementation
  - [ ] Add support for all volume types
  - [ ] Implement network configuration
  - [ ] Add ConfigMap/Secret support
  - [ ] Add health check support
  - [ ] Implement initContainer support
  - [ ] Support for depends_on and links
- [ ] **Kubernetes Transformer**
  - [ ] Define Kubernetes output schema
  - [ ] Implement Deployment transformation
  - [ ] Add health check support
  - [ ] Implement Service transformation
  - [ ] Add ConfigMap/Secret support
  - [ ] Implement PVC transformation
  - [ ] Implement ownerReferences for related resources
- [ ] **Flux Transformer**
  - [ ] Define Flux Kustomization schema
  - [ ] Define Flux HelmRelease schema
  - [ ] Define Flux GitRepository source schema
  - [ ] Define Flux HelmRepository source schema
  - [ ] Create main transformer logic for OAM to Flux conversion
  - [ ] Implement workload to Flux resource mapping
  - [ ] Add support for Flux namespace and tenant isolation
  - [ ] Add health check support
  - [ ] Implement Flux dependency management between resources
  - [ ] Create common Flux utilities and helpers
  - [ ] Add Flux-specific traits support (scaling, rollout strategies)
  - [ ] Document Flux transformer usage and examples

## OAM Features

- [ ] **Traits**
  - [ ] Define Trait schema
  - [ ] Implement scaling trait
  - [ ] Implement ingress/routing trait
  - [ ] Implement monitoring trait
  - [ ] Implement initContainer trait (e.g a trait that fixes permissions)
  - [ ] Create trait composition rules
- [ ] **Scopes**
  - [ ] Define Scope schema
  - [ ] Implement network scope
  - [ ] Implement health scope
  - [ ] Create scope boundary rules

## Workload Types

- [ ] Implement worker workload type
- [ ] Implement task/job workload type
- [ ] Implement database workload type

## Examples & Testing

- [ ] Create multi-component application example
- [ ] Add example with traits applied
- [ ] Add example with scopes
- [ ] Create validation test suite
- [ ] Add transformation test cases

## Documentation

- [ ] Write user guide
- [ ] Create API reference
- [ ] Add transformation examples
- [ ] Document CUE patterns used
- [ ] Create troubleshooting guide

## Future Enhancements

- [ ] Add support for parameters/overrides
- [ ] Implement application lifecycle hooks
- [ ] Implement application staging order and testing
- [ ] Implement a way to define upgrade validation for applications
- [ ] Create CLI tool for easier usage
- [ ] Add schema versioning support
- [ ] Implement component dependencies
