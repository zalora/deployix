services-to-nixos-config
=========================

Implement a set of defnixos services as a nixos config.

Arguments
----------

* `services`: A set of services (as defined in
  `<deployix/defnixos/services/README.md>`)

Return
------

A set that can be used as the `config` for a nixos module. Currently it defines
several services in `systemd.services` and two targets in `systemd.targets`.
The `defnixos` target pulls in all of the normal services, and the `on-demand`
target it pulls in all on-demand services.

Example
-------

See `<deployix/defnixos/nixos-wrappers/ipsec-wrapper.nix>` for an example
of how this is used.
