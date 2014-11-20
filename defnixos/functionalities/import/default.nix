defnix: functionalities-expr: pathspecs: let
  inherit (defnix.lib) nix-exec;

  inherit (nix-exec) bind map;

  inherit (defnix.nix-exec) sequence-pathspecs;

  io-paths = sequence-pathspecs pathspecs;
in bind io-paths (paths: bind (import paths.defnix nix-exec {
  config.target-system = "x86_64-linux";
}) (defnix: map (functionalities: {
  inherit paths functionalities;
}) (import functionalities-expr paths defnix)))
