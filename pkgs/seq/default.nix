defnix: let
  seq = defnix.build-support.compile-c [] ./seq.c;
in name: a: b: defnix.pkgs.execve name { filename = seq; argv = [ "seq" a b ]; }
