lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ run-script }:

pkgs@{ coreutils }:

name: text: run-script name { inherit text; } ''
  echo -n "$text" > $out
  ${coreutils}/bin/chmod +x $out
'')
