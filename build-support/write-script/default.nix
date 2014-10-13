defnix: let
  inherit (defnix.build-support) run-script;

  inherit (defnix.pkgs) coreutils;
in name: text: run-script name { inherit text; } ''
  echo -n "$text" > $out
  ${coreutils}/bin/chmod +x $out
''
