defnix:

addr: let
  inherit (defnix.build-support) compile-c compile-arguments;

  inherit (defnix.lib) socket-address-families;

  inherit (addr) family;

  flag = if family == socket-address-families.AF_UNIX
    then "UNIX"
    else "IPV6";

  so = compile-c [ "-shared" "-fPIC" "-DDEFNIX_SOCKET_${flag}" ] ./socket.so.c;

  address = if family == socket-address-families.AF_UNIX
    then addr.path
    else addr.port;
in compile-arguments "socket-activation-args" [ so "activate" address ]
