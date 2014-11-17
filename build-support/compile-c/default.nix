defnix:

flags: c: let
  inherit (defnix.build-support) output-to-argument cc patchelf binutils;

  inherit (defnix.pkgs) coreutils;

  inherit (defnix.config) target-system;

  base = c.name or (baseNameOf (toString c));

  base-flags = [ "-Wall" "-Werror" "-O3" "-std=c11" "-o" "@out" ];

  compile-strip-and-patchelf = output-to-argument (derivation {
    name = "compile-strip-and-patchelf";

    system = target-system;

    builder = cc;

    PATH = "${coreutils}/bin";

    args = base-flags ++ [
      ./compile-strip-and-patchelf.c
      "-DCOMPILER=\"${cc}\""
      "-DPATCHELF=\"${patchelf}/bin/patchelf\""
      "-DSTRIP=\"${if target-system == "x86_64-darwin"
        then "${coreutils}/bin/true"
        else "${binutils}/bin/strip"}\""
    ];
  });
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  system = target-system;

  builder = compile-strip-and-patchelf;

  PATH = "${coreutils}/bin";

  args = base-flags ++ [ c ] ++ flags;
})
