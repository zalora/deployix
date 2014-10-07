lib: lib.composable-set ((lib.import-subdirs ./. [
  "calculate-id"
]) // {
  target-system = lib.composable [ ] "x86_64-linux";
})
