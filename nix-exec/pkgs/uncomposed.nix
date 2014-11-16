lib: {
  nix-exec = defnix: defnix.nixpkgs.nix-exec;

  nixops = defnix: "${defnix.nixpkgs.nixops}/bin/nixops";
}
