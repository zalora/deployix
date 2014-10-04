lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ output-to-argument, cc, system, patchelf }:

pkgs@{ coreutils }:

flags: c: let
  base = c.name or baseNameOf (toString c);

  compile-and-patchelf = output-to-argument (derivation {
    name = "compile-and-patchelf";

    inherit system;

    builder = cc;

    PATH = "${coreutils}/bin";

    args = [
      ./compile-and-patchelf.c
      "-O3"
      "-Wl,-S"
      "-o"
      "@out"
      "-DCOMPILER=\"${cc}\""
      "-DPATCHELF=\"${patchelf}/bin/patchelf\""
    ];
  });
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  inherit system;

  builder = compile-and-patchelf;

  PATH = "${coreutils}/bin";

  args = [ c "-Wl,-S" "-O3" "-std=c11" "-o" "@out" ] ++ flags;
}))
