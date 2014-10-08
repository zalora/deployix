lib: lib.composable [ "build-support" "eval-support" ] (

build-support@{ compile-c, system }:

eval-support@{ eval-system }:

# verify target-id-t et. al. if adding a new system
assert builtins.elem system [ "x86_64-linux" "i686-linux" ];

let
  /* If overriding because of a clash (rather than because a specific uid
   * is needed), please use a uid whose binary representation has a null
   * byte in the middle so it's sure not to clash again
   */
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

in name: hardcodes.${name} or (import (derivation {
  name = "${name}-id.nix";

  system = eval-system;

  builder = calculate-id;

  args = [ (builtins.hashString "sha256" name) ];
})))
