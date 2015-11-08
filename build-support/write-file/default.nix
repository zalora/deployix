deployix: let
  inherit (deployix.build-support) run-script;
in name: text: run-script name { inherit text; } ''echo -n "$text" > $out''
