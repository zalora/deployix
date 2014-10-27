nix-exec-lib: let
  lib = import ./lib nix-exec-lib;

  uncomposed = import ./uncomposed.nix lib;

  deep-call = self:
    let go = x: has-overrides: overrides: if builtins.isAttrs x
      then lib.map-attrs (name: value:
        go value (has-overrides && overrides ? name) overrides.name
      ) x else if has-overrides then overrides else x self;
  in go;
in overrides@{ config ? {}, ... }: nix-exec-lib.map (uncomposed: let
  self = (deep-call self uncomposed true overrides) // {
    inherit lib;

    config = {
      target-system = builtins.currentSystem;

      eval-system = builtins.currentSystem;
    } // config;
  };
in self) uncomposed
