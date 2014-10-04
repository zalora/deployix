lib: lib.composable [ "build-support" ] (

build-support@{ run-script }:

name: text: run-script name { inherit text; } ''echo -n "$text" > $out'')
