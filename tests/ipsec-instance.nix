# this file must `upcast build'.
{ lib, ... }:
{
  resources.machines.test = { ... }: {
    imports = [
      ./../nixos-modules/ipsec-wrapper.nix
    ];
  };
}
