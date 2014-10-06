lib: lib.composable [ "build-support" ] (

build-support@{ compile-c }:

compile-c [ "-Wl,-s" ] ./notify-readiness.c)
