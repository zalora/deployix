let
  defnix = import ../. {};
in
{ compile-c ? defnix.compile-c
}:

drv: drv // (derivation (drv.drvAttrs // {
  builder = compile-c ./run-in-userns.c;

  args = [ drv.drvAttrs.builder ] ++ (drv.drvAttrs.args or []);

  # Can't enter a userns inside of a chroot
  __noChroot = true;
}))
