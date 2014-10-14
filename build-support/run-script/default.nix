defnix: let
  inherit (defnix.pkgs) sh;

  inherit (defnix.config) target-system;
in name: env: script: derivation (env // {
  inherit name script;

  system = target-system;

  builder = sh;

  args = [ "-e" "-c" "eval \"$script\"" ];
})
