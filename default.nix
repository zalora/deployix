{ pkgs ? import <nixpkgs> {}
}:

{
  inherit pkgs;

  output-to-argument =
    import ./output-to-argument { inherit (pkgs) runCommand; };
}
