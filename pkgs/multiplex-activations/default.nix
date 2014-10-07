lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ compile-c }:

pkgs@{ execve, run-with-settings }:

activations: assert activations != []; let
  multiplex-activations =
    compile-c [ "-ldl" "-Wl,-s" ] ./multiplex-activations.c;

  self = start: assert activations != []; let
    name = start.name or (baseNameOf (toString start));
  in (execve "activate-${name}" {
    filename = multiplex-activations;

    argv = [ "multiplex-activations" start name ] ++ activations;
  }) // {
    run-with-settings = settings: self (run-with-settings start settings);
  };
in self)
