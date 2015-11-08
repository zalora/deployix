deployix:

activations: assert activations != []; let
  inherit (deployix.build-support) compile-c;

  inherit (deployix.pkgs) execve run-with-settings;

  inherit (deployix.defnixos.activations) activation-header;

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
      parent-settings = {
        working-directory = settings.working-directory or null;
      };

      child-settings = removeAttrs settings [ "working-directory" ];
    in self parent-settings (run-with-settings start child-settings);
  };
in self {}
