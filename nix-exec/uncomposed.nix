lib: (lib.recursive-import ./.) // {
  # Spawn a program, throwing if it fails
  spawn-successful = defnix: prog: argv: lib.nix-exec.map ({ signalled, code }:
    if signalled
      then throw "${prog} killed by signal ${toString code}"
    else if code != 0
      then throw "${prog} exited with non-zero code ${
        toString code
      }"
      else null
  ) (defnix.nix-exec.spawn prog argv);
}
