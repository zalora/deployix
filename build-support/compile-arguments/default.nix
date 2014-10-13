defnix:

name: args: let
  inherit (defnix.build-support) compile-c;

  compile-arguments = compile-c [] ./compile-arguments.c;
in derivation {
  name = "${name}-arguments";

  builder = compile-arguments;

  args = builtins.concatLists (map (arg:
    [ (builtins.typeOf (arg.outPath or arg)) arg ]
  ) args);

  inherit (compile-arguments) system;
}
