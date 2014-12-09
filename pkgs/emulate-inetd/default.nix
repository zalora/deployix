defnix: let
  emulate-inetd = defnix.build-support.compile-c [] ./emulate-inetd.c;
in pkg: defnix.pkgs.execve "emulate-inetd-${defnix.lib.hashless-basename pkg}" {
  filename = emulate-inetd;

  argv = [ "emulate-inetd" (defnix.lib.hashless-basename pkg)pkg ];
}
