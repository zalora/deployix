defnix: let
  inherit (defnix.build-support) compile-cc;

  inherit (defnix.pkgs) nix boehmgc;

  so = compile-cc [
    "-shared"
    "-fPIC"
    "-I${nix}/include/nix"
    "-I${boehmgc}/include"
    "-undefined" "dynamic_lookup"
  ] ./spawn.so.cc;
in defnix.lib.nix-exec.dlopen so "nix_spawn" 2
