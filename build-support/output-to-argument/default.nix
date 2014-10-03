lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ run-script, cc }:

pkgs@{ coreutils }:

drv: drv // (derivation (drv.drvAttrs // {
  builder = run-script "output-to-argument" {}
    "PATH=${coreutils}/bin ${cc} -std=c99 -O3 ${./output-to-argument.c} -o $out";

  args = [ drv.drvAttrs.builder ] ++ (drv.drvAttrs.args or []);
})))
