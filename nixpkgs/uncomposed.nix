lib: let
  inherit (lib) nix-exec;

  inherit (nix-exec) sequenceAttrs;

  inherit (nix-exec.builtins) fetchgit;

  /* Note! When updating nixpkgs, please only only update attribtues in
   * pkgs that you've actually tested, and keep the rest at the version of
   * nixpkgs they're currently using
   */
  nixpkgs-sets = sequenceAttrs {
    nixpkgs-499c510 = nix-exec.map (src:
      let fn = import src; in system: fn { inherit system; }
    ) (fetchgit {
      url = "git://github.com/NixOS/nixpkgs.git";

      rev = "499c51016ef67bd0b158528dbff17ed6ecedd78b";
    });

    nixpkgs-c8be814 = nix-exec.map (src:
      let fn = import src; in system: fn { inherit system; }
    ) (fetchgit {
      url = "git://github.com/NixOS/nixpkgs.git";

      rev = "c8be814f254311ca454844bdd34fd7206e801399";
    });
  };

  haskellPackages = pkgs-fun: system: (pkgs-fun system).haskellPackages;

  inherit-pkgs = lib.map-attrs (pkg: pkgs-fun: defnix:
    (pkgs-fun defnix.config.target-system).${pkg}
  );
in lib.nix-exec.map (sets: (inherit-pkgs {
  gcc = sets.nixpkgs-499c510;

  coreutils = sets.nixpkgs-499c510;

  bash = sets.nixpkgs-499c510;

  strongswan = sets.nixpkgs-499c510;

  kmod = sets.nixpkgs-499c510;

  openssl = sets.nixpkgs-499c510;

  patchelf = sets.nixpkgs-499c510;

  php = sets.nixpkgs-499c510;

  nginx = sets.nixpkgs-499c510;

  binutils = sets.nixpkgs-499c510;
}) // {
  haskellPackages = inherit-pkgs {
    ghcPlain = haskellPackages sets.nixpkgs-c8be814;
  };
}) nixpkgs-sets
