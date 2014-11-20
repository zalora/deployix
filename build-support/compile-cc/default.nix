defnix:

flags: cc: let
  inherit (defnix.build-support) compile-c cxx patchelf binutils output-to-argument libcxx;

  inherit (defnix.pkgs) coreutils;

  inherit (defnix.config) system;

  base = cc.name or (baseNameOf (toString cc));

  base-flags = [ "-Wall" "-Werror" "-O3" "-std=c++11" "-o" "@out" ] ++ (
    if system == "x86_64-darwin"
      then [
        "-stdlib=libc++"
        "-L${libcxx}/lib"
        "-isystem" "${libcxx}/include/c++/v1"
      ]
      else []
  );

  compile-strip-and-patchelf = compile-c ([
    "-DCOMPILER=\"${cxx}\""
  ] ++ (if system == "x86_64-darwin" then [] else [
    "-DPATCHELF=\"${patchelf}/bin/patchelf\""
    "-DSTRIP=\"${binutils}/bin/strip\""
  ])) ../compile-c/compile-strip-and-patchelf.c;
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 3) base;

  NIX_DONT_SET_RPATH = if system == "x86_64-darwin"
    then "1"
    else null;

  __ignoreNulls = true;

  inherit system;

  builder = compile-strip-and-patchelf;

  PATH = "${coreutils}/bin";

  args = base-flags ++ [ cc ] ++ flags;
})
