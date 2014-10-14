overrides@{ config ? {}, ... }:

let
  lib = import ./lib;

  uncomposed = import ./uncomposed.nix lib;

  deep-call = x: has-overrides: overrides: if builtins.isAttrs x
    then lib.map-attrs (name: value:
      deep-call value (has-overrides && overrides ? name) overrides.name
    ) x else if has-overrides then overrides else x defnix;

  defnix = (deep-call uncomposed true overrides) // {
    inherit lib;

    config = {
      target-system = builtins.currentSystem;

      eval-system = builtins.currentSystem;
    } // config;
  };
in defnix
