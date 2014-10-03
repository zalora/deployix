lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ system }:

pkgs@{ sh }:

name: env: script: derivation (env // {
  inherit name script system;

  builder = sh;

  args = [ "-e" "-c" "eval \"$script\"" ];
}))
