defnix:

flags: cc: let
  inherit (defnix.build-support) compile-c cxx patchelf binutils output-to-argument;

  inherit (defnix.pkgs) coreutils;

  inherit (defnix.config) target-system;

  base = cc.name or (baseNameOf (toString cc));

  base-flags = [ "-Wall" "-Werror" "-O3" "-std=c++11" "-o" "@out" ];

  compile-strip-and-patchelf = compile-c [
    "-DCOMPILER=\"${cxx}\""
    "-DPATCHELF=\"${patchelf}/bin/patchelf\""
    "-DSTRIP=\"${binutils}/bin/strip\""
  ] ../compile-c/compile-strip-and-patchelf.c;
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 3) base;

  system = target-system;

  builder = compile-strip-and-patchelf;

  PATH = "${coreutils}/bin";

  args = base-flags ++ [ cc ] ++ flags;
})
