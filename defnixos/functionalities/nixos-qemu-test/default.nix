defnix: functionalities: let
  inherit (defnix.lib) map-attrs-to-list;

  get-attr-if-all-same = attr: let
    vals = map-attrs-to-list (name: value: value.${attr}) functionalities;

    val-head = builtins.head vals;
  in if defnix.lib.all (v: v == val-head) vals
    then val-head
    else throw "Deployments of functionalities with mixed ${attr} values not yet supported";

  nixpkgs = get-attr-if-all-same "nixpkgs-src";

  test-command = get-attr-if-all-same "unit-test-command";

  inherit (defnix.defnixos.functionalities) generate-nixos-config;
in (import "${toString nixpkgs}/nixos/lib/testing.nix" {
    inherit (defnix.config) system;
  }).simpleTest {
    testScript = ''
      startAll;
      $machine->waitForUnit("multi-user.target");
      $machine->succeed("${test-command}");
      $machine->shutdown;
    '';

    machine = { pkgs, ... }: { imports = [
      (generate-nixos-config functionalities).outPath
    ]; environment.systemPackages = [
      /* Hack to ensure the test-command is callable inside the vm */
      ((builtins.substring 0 0 test-command) + pkgs.systemd)
    ]; };
  }
