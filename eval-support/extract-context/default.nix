deployix: deployix.lib.nix-exec.builtins.unsafe-perform-io (
  deployix.nix-exec.compile-plugin [] ./extract-context.so.cc "setup_extract_context" 0
)
