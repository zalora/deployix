deployix: let
  emulate-inetd = deployix.build-support.compile-c [] ./emulate-inetd.c;
in pkg: deployix.pkgs.execve "emulate-inetd-${deployix.lib.hashless-basename pkg}" {
  filename = emulate-inetd;

  argv = [ "emulate-inetd" (deployix.lib.hashless-basename pkg)pkg ];
}
