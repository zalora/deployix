deployix: flags: cc: let
  inherit (deployix.native.build-support) compile-cc;

  inherit (deployix.native.pkgs) nix boehmgc;

  so = compile-cc ([
    "-shared"
    "-fPIC"
    "-I${nix}/include/nix"
    "-I${boehmgc}/include"
  ] ++ (if deployix.native.config.system == "x86_64-darwin"
    then [ "-undefined" "dynamic_lookup" ]
    else []
  ) ++ flags) cc;
in deployix.lib.nix-exec.dlopen-variadic so
