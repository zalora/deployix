lib: lib.composable [ "build-support" ] (

build-support@{ compile-c, compile-arguments }:

addr: let
  inherit (addr) family;

  flag = if family == lib.socket-address-families.AF_UNIX
    then "UNIX"
    else "IPV6";

  so = compile-c [ "-shared" "-fPIC" "-DDEFNIX_SOCKET_${flag}" ] ./socket.so.c;

  address = if family == lib.socket-address-families.AF_UNIX
    then addr.path
    else addr.port;
in compile-arguments "socket-activation-args" [ so "activate" address ])
