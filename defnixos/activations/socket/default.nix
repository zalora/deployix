lib: lib.composable [ "build-support" ] (

build-support@{ compile-c, compile-arguments }:

{ addr }: let
  so = compile-c [ "-shared" "-fPIC" ] ./socket.so.c;
in compile-arguments "socket-activation-args" [ so "activate" addr ])
