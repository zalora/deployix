defnix: let
  inherit (defnix.build-support) compile-cc;

  inherit (defnix.pkgs) nix boehmgc gnupg;

  so = compile-cc [
    "-shared"
    "-fPIC"
    "-I${nix}/include/nix"
    "-I${boehmgc}/include"
    "-Wno-write-strings"
    ''-DGPG="${gnupg}/bin/gpg2"''
  ] ./decrypt-file.so.cc;
in defnix.lib.nix-exec.dlopen so "decrypt" 3
