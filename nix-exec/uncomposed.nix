lib: (lib.recursive-import ./.) // {
  # Spawn a program, throwing if it fails
  spawn-successful = deployix: prog: argv: lib.nix-exec.map ({ signalled, code }:
    if signalled
      then throw "${prog} killed by signal ${toString code}"
    else if code != 0
      then throw "${prog} exited with non-zero code ${
        toString code
      }"
      else null
  ) (deployix.nix-exec.spawn prog argv);
}
