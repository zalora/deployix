lib: lib.composable-set ((lib.import-subdirs ./. [
  "compile-c"
  "output-to-argument"
  "run-script"
  "write-script"
]) // {
  cc = lib.composable [ "nixpkgs" ] (nixpkgs@{ cc }: cc);

  system = lib.composable [ ] builtins.currentSystem;
})
