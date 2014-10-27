defnix: let
  inherit (defnix.build-support) compile-cc;

  inherit (defnix.pkgs) nix boehmgc;

  so = compile-cc [
    "-shared"
    "-fPIC"
    "-I${nix}/include/nix"
    "-I${boehmgc}/include"
  ] ./getenv.so.cc;
in defnix.lib.nix-exec.dlopen so "nix_getenv" 1
