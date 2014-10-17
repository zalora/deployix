lib: (lib.recursive-import ./.) // {
  # C compiler
  cc = defnix: "${defnix.nixpkgs.gcc}/bin/cc";

  # Utility to modify the dynamic linker and RPATH of elf executables
  # See http://nixos.org/patchelf.html
  patchelf = defnix: defnix.nixpkgs.patchelf;

  # Binary utilities
  binutils = defnix: defnix.nixpkgs.binutils;

  # Haskell compiler
  ghc = defnix: "${defnix.nixpkgs.haskellPackages.ghcPlain}/bin/ghc";
}
