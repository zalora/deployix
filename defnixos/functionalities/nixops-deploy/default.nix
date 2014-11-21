defnix:

{ functionalities, target, name, nixpkgs }: let
  inherit (defnix.native.nix-exec.pkgs) nixops;

  inherit (defnix.native.build-support) write-file;

  inherit (defnix.nix-exec) spawn;

  inherit (defnix.lib) map-attrs-to-list join;

  inherit (defnix.lib.nix-exec) bind;

  inherit (defnix.defnixos.functionalities) generate-nixos-config;

  expr = write-file "deployment.nix" ''
    {
      machine = { pkgs, ... }: {
        imports = [ ${generate-nixos-config functionalities} ];
        ${if target == "virtualbox" then "config = {"
          + "\n      deployment.targetEnv = \"virtualbox\";"
          + "\n      deployment.virtualbox.memorySize = 2048;"
          + "\n      deployment.virtualbox.headless = true;"
        + "\n    };" else ""}
      };
    }
  '';

  run-nixops = cmd:
    spawn nixops [ cmd "-d" name "-I" "nixpkgs=${nixpkgs}" expr ];

  modify = run-nixops "modify";

  create = run-nixops "create";

  deploy = spawn nixops [
    "deploy"
    "-d"
    name
    "--option"
    "allow-unsafe-native-code-during-evaluation"
    "true"
  ];

  run = bind modify ({ signalled, code }: if signalled
    then throw "nixops modify killed by signal ${toString code}"
    else if code != 0
      then bind create ({ signalled, code }: if signalled
        then throw "nixops create killed by signal ${toString code}"
        else if code != 0
          then throw "nixops create exited with code ${toString code}"
          else deploy)
      else deploy);
in run
