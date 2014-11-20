defnixos
=========

Defnixos is a library for declarative service-oriented specifications of
machines and deployments.

The primary interface for `defnixos` is through the `service` abstraction.
Defnixos defines a number of service functions, and more can be defined
easily. The service interface is intended to be implementation agnostic, and
many implementations to map defnixos services to a deployment action are
possible and expected. For example, we currently have
`services-to-nixos-config`, which implements services as `NixOS` modules,
and `ipsec-wrapper.nix`, which uses `services-to-nixos-config` to allow
services to depend on secure ipsec tunnels to other hosts.

`defnixos` services can be activated on-demand using `activations`. A
generalization of the socket activation provided by `inetd` or `systemd`, these
functions allow starting a service when arbitrary conditions are met.

Services can be grouped together into `functionalities`, and there are a
number of possibility functionality implementations that can take a set
of functionalities and actualize them in some way. For example, we currently
have `nixops-deploy` which deploys a set of functionalities to a nixops
machine.

Please see the READMEs in the `services`, `activations`, and
`functionality-implementations` directories for more details.
