deployix:

flags: c: let
  inherit (deployix.build-support) output-to-argument cc patchelf binutils;

  inherit (deployix.pkgs) coreutils;

  inherit (deployix.config) system;

  base = c.name or (baseNameOf (toString c));

  base-flags = [ "-Wall" "-Werror" "-O3" "-std=c11" "-o" "@out" ];

  compile-strip-and-patchelf = output-to-argument (derivation {
    name = "compile-strip-and-patchelf";

    inherit system;

    builder = cc;

    PATH = "${coreutils}/bin";

    args = base-flags ++ [
      ./compile-strip-and-patchelf.c
      "-DCOMPILER=\"${cc}\""
    ] ++ (if system == "x86_64-darwin" then [] else [
      "-DPATCHELF=\"${patchelf}/bin/patchelf\""
      "-DSTRIP=\"${binutils}/bin/strip\""
    ]);
  });
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  NIX_DONT_SET_RPATH = if system == "x86_64-darwin"
    then "1"
    else null;

  __ignoreNulls = true;

  inherit system;

  builder = compile-strip-and-patchelf;

  PATH = "${coreutils}/bin";

  args = base-flags ++ [ c ] ++ flags;
})
