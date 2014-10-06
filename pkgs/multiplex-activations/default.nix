lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ compile-c }:

pkgs@{ execve }:

start: activations: assert activations != []; let
  multiplex-activations =
    compile-c [ "-ldl" "-Wl,-s" ] ./multiplex-activations.c;

  name = start.name or (baseNameOf (toString start));
in execve "activate-${name}" {
  filename = multiplex-activations;

  argv = [ "multiplex-activations" start name ] ++ activations;
})
