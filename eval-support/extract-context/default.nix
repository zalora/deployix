defnix: defnix.lib.nix-exec.builtins.unsafe-perform-io (
  defnix.nix-exec.compile-plugin [] ./extract-context.so.cc "setup_extract_context" 0
)
