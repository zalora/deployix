{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

rec {
  output-to-argument =
    import ./output-to-argument { inherit (pkgs) runCommand; };

  compile-c = import ./compile-c {
    inherit output-to-argument system;
    inherit (pkgs) coreutils;
    cc = "${pkgs.stdenv.gcc}/bin/gcc";
  };
}
