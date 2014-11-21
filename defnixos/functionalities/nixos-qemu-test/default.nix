defnix: let
  inherit (defnix.defnixos.functionalities) generate-nixos-config;
in { functionalities, nixpkgs, test-command }:
  (import "${toString nixpkgs}/nixos/lib/testing.nix" {
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
