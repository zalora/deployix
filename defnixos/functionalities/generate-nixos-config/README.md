generate-nixos-config
=====================

Turn a set of functionalities into a `NixOS` configuration module.

Arguments
----------

* `functionalities`: The set of functionalities

Return
-------

A derivation whose output is a nix expression that describes the `systemd`
services and targets needed to implement `functionalities` on NixOS.
