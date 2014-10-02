{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}: let
args = { inherit pkgs defnix; };
defnix = {
  deflib = import ./deflib;

  toolchain = import ./toolchain args;

  defnixos = import ./defnixos args;
}; in defnix
