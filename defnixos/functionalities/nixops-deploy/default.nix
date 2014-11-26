defnix: functionalities: let
  get-attr-if-all-same = attr: let
    vals = builtins.concatLists (map-attrs-to-list (name: value:
      if value ? ${attr} then [ value.${attr} ] else []
    ) functionalities);

    val-head = builtins.head vals;
  in if builtins.length vals == 0
    then throw "No functionalities have a value for ${attr}"
  else if defnix.lib.all (v: v == val-head) vals
    then val-head
    else throw "Deployments of functionalities with mixed ${attr} values not yet supported";

  target = get-attr-if-all-same "nixops-deploy-target";

  name = get-attr-if-all-same "nixops-name";

  description = get-attr-if-all-same "nixops-description";

  nixpkgs = get-attr-if-all-same "nixpkgs-src";

  inherit (defnix.native.nix-exec.pkgs) nixops;

  inherit (defnix.native.build-support) write-file;

  inherit (defnix.nix-exec) spawn;

  inherit (defnix.lib) map-attrs-to-list join;

  inherit (defnix.lib.nix-exec) bind;

  inherit (defnix.defnixos.functionalities) generate-nixos-config;

  target-expr = builtins.toString (if target == "virtualbox"
    then ./virtualbox.nix
  else if target == "ec2"
    then import ./ec2.nix { inherit name; }
    else null);

  expr = write-file "deployment.nix" ''
    {
      network.description = "${description}";

      require = [ ${target-expr} ];

      machine = { pkgs, ... }: {
        imports = [ ${generate-nixos-config functionalities} ];
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
