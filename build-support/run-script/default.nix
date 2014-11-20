defnix: let
  inherit (defnix.pkgs) sh;

  inherit (defnix.config) system;
in name: env: script: derivation (env // {
  inherit name script system;

  builder = sh;

  args = [ "-e" "-c" "eval \"$script\"" ];
})
