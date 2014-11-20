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
  call = self: isNative: (deep-call self uncomposed true overrides) // {
    inherit lib native;

    config = if isNative
      then (config // {
        system = builtins.currentSystem;
      }) else config;
  };

  native = call native true;

  self = if (config.system or builtins.currentSystem) == builtins.currentSystem
    then native
    else call self false;
in self) uncomposed
