defnix:

flags: c: let
  inherit (defnix.build-support) output-to-argument cc patchelf;

  inherit (defnix.pkgs) coreutils;

  base = c.name or (baseNameOf (toString c));

  base-flags = [ "-Wall" "-Werror" "-Wl,-S" "-O3" "-std=c11" "-o" "@out" ];

  compile-and-patchelf = output-to-argument (derivation {
    name = "compile-and-patchelf";

    inherit (patchelf) system;

    builder = cc;

    PATH = "${coreutils}/bin";

    args = base-flags ++ [
      ./compile-and-patchelf.c
      "-DCOMPILER=\"${cc}\""
      "-DPATCHELF=\"${patchelf}/bin/patchelf\""
    ];
  });
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  inherit (compile-and-patchelf) system;

  builder = compile-and-patchelf;

  PATH = "${coreutils}/bin";

  args = base-flags ++ [ c ] ++ flags;
})
