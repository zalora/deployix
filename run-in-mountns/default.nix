let
  defnix = import ../. {};
in
{ compile-c ? defnix.compile-c
, run-in-userns ? defnix.run-in-userns
}:

drv: run-in-userns (drv // (derivation (drv.drvAttrs // {
  builder = compile-c ./run-in-mountns.c;

  args = [ drv.drvAttrs.builder ] ++ (drv.drvAttrs.args or []);
})))
