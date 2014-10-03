lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ output-to-argument, cc, system }:

pkgs@{ coreutils }:

c: let
  base = c.name or baseNameOf (toString c);
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  inherit system;

  builder = cc;

  PATH = "${coreutils}/bin";

  args = [ c "-O3" "-o" "@out" ];
}))
