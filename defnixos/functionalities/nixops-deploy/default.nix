defnix:

{ functionalities, target, name, nixpkgs }: let
  inherit (defnix.nix-exec.pkgs) nixops nix-exec;

  inherit (defnix.nix-exec) spawn;

  inherit (defnix.lib) map-attrs-to-list join;

  inherit (defnix.lib.nix-exec) bind;

  # Our generated nix expression will reference .drvs, but we don't
  # want to require building their outputs to write the expressions
  discard = builtins.unsafeDiscardOutputDependency;

  expr = defnix.build-support.write-file "deployment.nix" ''
    {
      machine = { pkgs, ... }: let
        nix-exec-lib = import ${nix-exec}/share/nix/lib.nix;

        unsafe-perform-io = import ${nix-exec}/share/nix/unsafe-perform-io.nix;

        defnix = unsafe-perform-io (import ${toString ../../..} nix-exec-lib {
          config.system = pkgs.system;
        });

        svcs = {
          ${join "\n          " (map-attrs-to-list (name: { service, ... }:
            "\"${name}\" = {\n        " + "start = (import ${
              discard service.start.drvPath
            }).${service.start.outputName};\n        " + "initializer = ${
              if service ? initializer
                then "(import ${
                  discard service.initializer.drvPath
                }).${service.initializer.outputName}"
                else "null"
            };\n        " + "on-demand = ${if service.on-demand or false
              then "true"
              else "false"
            };\n      };"
          ) functionalities)}
        };
      in defnix.defnixos.nixos-wrappers.services-to-nixos-config svcs${
        if target == "virtualbox" then " // {" +
          "\n    deployment.targetEnv = \"virtualbox\";" +
          "\n    deployment.virtualbox.memorySize = 2048;" +
          "\n    deployment.virtualbox.headless = true;" +
        "\n  }" else ""};
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
