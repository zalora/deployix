lib: (lib.recursive-import ./.) // {
  # C compiler
  cc = defnix: "${defnix.nixpkgs.gcc}/bin/cc";

  # C++ compiler
  cxx = defnix: "${defnix.nixpkgs.gcc}/bin/c++";

  libcxx = defnix: defnix.nixpkgs.libcxx;

  # Utility to modify the dynamic linker and RPATH of elf executables
  # See http://nixos.org/patchelf.html
  patchelf = defnix: defnix.nixpkgs.patchelf;

  # Binary utilities
  binutils = defnix: defnix.nixpkgs.binutils;

  # Haskell compiler
  ghc = defnix: "${defnix.nixpkgs.haskellPackages.ghcPlain}/bin/ghc";

  # Run a series of tests
  write-test-script = defnix: let
    inherit (defnix.pkgs) sh;

    inherit (defnix.build-support) write-script;

    inherit (defnix.lib) join map-attrs-to-list;
  in tests: write-script "tests" ''
    #!${sh} -e

    failed=
    ${join "\n" (map-attrs-to-list (test-name: test-command: ''
      echo Running test ${test-name} >&2
      ${test-command} || failed=1
    '') tests)}
    if [ -n "$failed" ]; then
      echo At least one test failed >&2
      exit 1
    fi
  '';
}
