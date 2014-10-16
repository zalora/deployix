defnix:

activations: assert activations != []; let
  inherit (defnix.build-support) compile-c;

  inherit (defnix.pkgs) execve run-with-settings;

  inherit (defnix.defnixos.activations) activation-header;

  multiplex-activations = compile-c [
    "-ldl"
    "-Wl,-s"
    ''-DACTIVATION_HEADER="${activation-header}"''
  ] ./multiplex-activations.c;

  self = start: assert activations != []; let
    name = start.name or (baseNameOf (toString start));
  in (execve "activate-${name}" {
    filename = multiplex-activations;

    argv = [ "multiplex-activations" start name ] ++ activations;
  }) // {
    run-with-settings = settings: self (run-with-settings start settings);
  };
in self
