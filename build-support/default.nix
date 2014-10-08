lib: lib.composable-set ((lib.import-subdirs ./. [
  "compile-c"
  "output-to-argument"
  "run-script"
  "write-script"
  "write-file"
  "compile-arguments"
]) // {
  cc = lib.composable [ "nixpkgs" ] (nixpkgs@{ gcc }: "${gcc}/bin/cc");

  system = lib.composable [ ] builtins.currentSystem;

  patchelf = lib.composable [ "nixpkgs" ] (nixpkgs@{ patchelf }: patchelf);

  ghc = lib.composable [ "nixpkgs" ] (nixpkgs@{ ghcPlain }: ghcPlain);
})
