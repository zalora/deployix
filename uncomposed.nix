lib: lib.nix-exec.map (nixpkgs:
  (removeAttrs (lib.recursive-import ./.) [ ".git" "lib" ]) // { inherit nixpkgs; }
) (import ./nixpkgs/uncomposed.nix lib)
