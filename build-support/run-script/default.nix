defnix: let
  inherit (defnix.pkgs) sh;
in name: env: script: derivation (env // {
  inherit name script;

  inherit (sh) system;

  builder = sh;

  args = [ "-e" "-c" "eval \"$script\"" ];
})
