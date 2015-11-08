deployix: let
  seq = deployix.build-support.compile-c [] ./seq.c;
in name: a: b: deployix.pkgs.execve name { filename = seq; argv = [ "seq" a b ]; }
