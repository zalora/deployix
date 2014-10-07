let
  lib = import ./lib;

  subsets = lib.import-subdirs ./. [
    "eval-support"
    "build-support"
    "pkgs"
    "defnixos"
    "nixpkgs"
  ];
in subsets // {
  compose = lib.top-nested-compose subsets;

  inherit lib;
}
