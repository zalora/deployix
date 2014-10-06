lib: lib.composable [ "build-support" ] (

build-support@{ compile-c, system }:

name: args: let
  compile-arguments = compile-c [] ./compile-arguments.c;
in derivation {
  name = "${name}-arguments";

  builder = compile-arguments;

  args = builtins.concatLists (builtins.map (arg:
    [ (builtins.typeOf (arg.outPath or arg)) arg ]
  ) args);

  inherit system;
})
