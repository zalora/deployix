defnix:

activations: assert activations != []; let
  inherit (defnix.build-support) compile-c;

  inherit (defnix.pkgs) execve run-with-settings;

  inherit (defnix.defnixos.activations) activation-header;

  multiplex-activations = compile-c [
    "-ldl"
    ''-DACTIVATION_HEADER="${activation-header}"''
  ] ./multiplex-activations.c;

  self = settings: start: assert activations != []; let
    name = start.name or (baseNameOf (toString start));
  in (execve "activate-${name}" {
    filename = multiplex-activations;

    inherit settings;

    argv = [ "multiplex-activations" start name ] ++ activations;
  }) // {
    run-with-settings = settings: let
      parent-settings = { inherit (settings) working-directory; };

      child-settings = removeAttrs settings [ "working-directory" ];
    in self parent-settings (run-with-settings start child-settings);
  };
in self {}
