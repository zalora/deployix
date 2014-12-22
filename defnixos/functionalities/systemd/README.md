systemd
========

Activate a set of functionalities on a systemd-based system

Arguments
----------

* `service-prefix`: The prefix for the services these functionalities provide.
  This allows multiple functionality sets to be deployed side-by-side on the
  same system without stepping on each other
* `functionalities`: The set of functionalities to deploy

Custom functionalities attributes
----------------------------------

* `singleton`: If `true`, this functionality's service is *not* prefix with
  `service-prefix`. This is for services that can only exist once on a given
  machine, e.g. `strongswan`, and should only be used by functionality wrapper
  functions e.g. `ipsec`. `false` by default.

Return
-------

A derivation that builds a script to activate the set of functionalities.

Activation script
-----------------

The script produced by the `systemd` function also makes
`/nix/var/nix/profiles/defnixos/activate` a symlink to an activation script.
This script can be used to roll back to a previous generation. For example,
`/nix/var/nix/profiles/defnixos/activate /nix/var/nix/profiles/defnixos/sunrise-2-link`
will make the second generation of the `sunrise` deployment on this machine
active.
