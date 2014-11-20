defnix: flags: cc: let
  inherit (defnix.build-support) compile-cc;

  inherit (defnix.pkgs) nix boehmgc;

  so = compile-cc ([
    "-shared"
    "-fPIC"
    "-I${nix}/include/nix"
    "-I${boehmgc}/include"
  ] ++ (if defnix.config.target-system == "x86_64-darwin"
    then [ "-undefined" "dynamic_lookup" ]
    else []
  ) ++ flags) cc;
in defnix.lib.nix-exec.dlopen so
