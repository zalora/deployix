let
  defnix = import ../. {};
in
{ output-to-argument ? defnix.output-to-argument
, cc ? "${defnix.pkgs.stdenv.gcc}/bin/gcc"
, coreutils ? defnix.pkgs.coreutils
, system ? builtins.currentSystem
}:

drv: drv // (derivation (drv.drvAttrs // {
  builder = output-to-argument (derivation {
    name = "run-in-userns";

    inherit system;

    builder = cc;

    PATH = [ "${coreutils}/bin" ];

    args = [ ./run-in-userns.c "-O3" "-o" "@out" ];
  });

  args = [ drv.drvAttrs.builder ] ++ (drv.drvAttrs.args or []);

  # Can't enter a userns inside of a chroot
  __noChroot = true;
}))
