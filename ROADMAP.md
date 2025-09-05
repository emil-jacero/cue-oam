# Roadmap

- [x] Core API
- [x] Standard Traits
- [x] Standard schema
- [x] Pluggable provider system
- [ ] Add Database trait. A simple database utilizing the platform to deploy a container.
- [ ] Support Docker Compose as a provider
- [ ] Support TrueNAS as a provider (Docker compose like)
- [ ] Support Scopes. The ability to combine components into scopes where they share some trait. Should scopes make use of traits? Although specific to only scope
- [ ] Support Policies. The ability to add policies to an application, enforcing specific rules and behaviors at the application level.
- [ ] Create a CLI helper tool. Responsible for bootstrapping a CUE module with an example, or for listing and viewing traits, components, applications, scopes, policies and bundles. Would also be able to handle deployment of the generated resources.

## Future

- [ ] Support the [OSCAL](https://pages.nist.gov/OSCAL/) model
- [ ] Ability to bundle several Applications into a Bundle, that can be deployed as a whole onto a plattform.
- [ ] Support Scopes and Polices in Bundles. Meant to scope multiple applications or enforce certain policies on multiple applications.
- [ ] Ability to write workflows/pipelines. Tasks that execute in series, either in combination with Applications and Components or completely separately.
- [ ] Ability to query the kubernetes cluster. With this ability it would be possible to populate the platform capability list dynamically, meaning it would know exactly which capabilities a certain target platform has.
- [ ] Add support for trait/component dependecies. Meaning a trait within a component can have a depencency that is external to the application. For example, for a CNPG database trait it would have a dependency on the application that ensures CNPG is deployed into the cluster.
