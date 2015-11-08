lib: (lib.recursive-import ./.) // {
  # C compiler
  cc = deployix: "${deployix.nixpkgs.gcc}/bin/cc";

  # C++ compiler
  cxx = deployix: "${deployix.nixpkgs.gcc}/bin/c++";

  libcxx = deployix: deployix.nixpkgs.libcxx;

  # Utility to modify the dynamic linker and RPATH of elf executables
  # See http://nixos.org/patchelf.html
  patchelf = deployix: deployix.nixpkgs.patchelf;

  # Binary utilities
  binutils = deployix: deployix.nixpkgs.binutils;

  # Haskell compiler
  ghc = deployix: "${deployix.nixpkgs.haskellPackages.ghcPlain}/bin/ghc";

  # The Stream EDitor
  sed = deployix: "${deployix.nixpkgs.gnused}/bin/sed";

  # Run a series of tests
  write-test-script = deployix: let
    inherit (deployix.pkgs) sh;

    inherit (deployix.build-support) write-script;

    inherit (deployix.lib) join map-attrs-to-list;
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
