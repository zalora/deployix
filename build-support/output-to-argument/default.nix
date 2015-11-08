deployix: let
  inherit (deployix.build-support) run-script cc;

  inherit (deployix.pkgs) coreutils;
in drv: drv // (derivation (drv.drvAttrs // {
  builder = run-script "output-to-argument" { PATH = "${coreutils}/bin"; }
    "${cc} -std=c99 -O3 ${./output-to-argument.c} -o $out";

  args = [ drv.drvAttrs.builder ] ++ (drv.drvAttrs.args or []);
}))
