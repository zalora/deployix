defnix: let
  inherit (defnix.build-support) compile-c;

  inherit (defnix.config) eval-system target-system;

  hardcodes = {
    root = 0;

    nobody = 65534;

    nogroup = 65534;
  };

  target-id-t = "uint32_t";

  target-id-t-format = "PRIu32";

  calculate-id = compile-c [
    "-DTARGET_ID_T=${target-id-t}"
    "-DTARGET_ID_T_FORMAT=${target-id-t-format}"
  ] ./calculate-id.c;
in

# verify target-id-t et. al. if adding a new system
assert builtins.elem target-system [ "x86_64-linux" "i686-linux" ];

name: hardcodes.${name} or (import (derivation {
  name = "${name}-id.nix";

  system = eval-system;

  builder = calculate-id;

  args = [ (builtins.hashString "sha256" name) ];
}))
