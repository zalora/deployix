deployix: let
  inherit (deployix.build-support) run-script;

  inherit (deployix.pkgs) coreutils;
in name: text: run-script name { inherit text; } ''
  echo -n "$text" > $out
  ${coreutils}/bin/chmod +x $out
''
