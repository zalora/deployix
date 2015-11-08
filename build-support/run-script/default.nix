deployix: let
  inherit (deployix.pkgs) sh;

  inherit (deployix.config) system;
in name: env: script: derivation (env // {
  inherit name script system;

  builder = sh;

  args = [ "-e" "-c" "eval \"$script\"" ];
})
