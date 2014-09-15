{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

rec {
  inherit pkgs;

  output-to-argument =
    import ./output-to-argument { inherit (pkgs) runCommand; };

  run-in-userns = import ./run-in-userns {
    inherit output-to-argument system;
    inherit (pkgs) coreutils;
    cc = "${pkgs.stdenv.gcc}/bin/gcc";
  };
}
