# Todo

## Nearterm

- [x] Refactor the Domain concept. It works fine for atomic traits, but for composite traits it faulters. Composite traits belong to multiple domains. Perhaps a redesigned architecture should define #AtomicTrait and #CompositeTrait and som logic to compile all domains for composite traits.
- [ ] Add a way to specify how a trait is applied. One could be "native", which has to be implemented directly in a transformer. The other could be "patch" which allows developers to create traits that behaves as patches but still rely on CUE's type safety.
- [ ] Support the provider Docker Compose
- [ ] Support the provider TrueNAS (Docker compose like)
- [ ] Support Scopes. The ability to combine components into scopes where they share some trait. These are special traits meant for mutation or governance
- [ ] Support Policies. The ability to add policies to a component or application, enforcing specific rules and behaviors. These should be implemented as Traits.
- [ ] Create a CLI helper tool. Responsible for bootstrapping a CUE module with an example, or for listing and viewing traits, components, applications, scopes, policies and bundles. Would also be able to handle deployment of the generated resources.

## Future

- [ ] Support the [OSCAL](https://pages.nist.gov/OSCAL/) model
- [ ] Ability to bundle several Applications into a Bundle, that can be deployed as a whole into a plattform.
- [ ] Support Scopes in Bundles. Meant to scope multiple applications or enforce certain policies or mutate resources for multiple applications.
- [ ] Ability to write workflows/pipelines. Tasks that execute in series, either in combination with Applications and Components or completely separately.
- [ ] Ability to query the kubernetes cluster. With this ability it would be possible to populate the platform capability list dynamically, meaning it would know exactly which capabilities a certain target platform has.
- [ ] Add support for trait/component dependecies. Meaning a trait within a component can have a depencency that is external to the application. For example, for a CNPG database trait it would have a dependency on the application that ensures CNPG is deployed into the cluster.
