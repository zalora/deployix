lib: lib.composable-set ((lib.import-subdirs ./. [
  "calculate-id"
]) // {
  eval-system = lib.composable [ ] builtins.currentSystem;
})
