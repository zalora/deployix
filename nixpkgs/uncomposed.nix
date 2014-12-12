lib: let
  inherit (lib) nix-exec;

  inherit (nix-exec) sequence-attrs;

  inherit (nix-exec.builtins) fetchgit;

  /* Note! When updating nixpkgs, please only only update attribtues in
   * pkgs that you've actually tested, and keep the rest at the version of
   * nixpkgs they're currently using
   */
  nixpkgs-sets = sequence-attrs {
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

    nixpkgs-8b9b0d9 = nix-exec.map (src:
      let fn = import src; in system: fn { inherit system; }
    ) (fetchgit {
      url = "git://github.com/NixOS/nixpkgs.git";

      rev = "8b9b0d95a08706aa0757150d5fb310d545ef9176";
    });

    nixpkgs-86055e2 = nix-exec.map (src:
      let fn = import src; in system: fn { inherit system; }
    ) (fetchgit {
      url = "git://github.com/NixOS/nixpkgs.git";

      rev = "86055e2f0071a4c865561b2ff26081c31145894b";
    });
  };

  haskellPackages = pkgs-fun: system: (pkgs-fun system).haskellPackages;

  inherit-pkgs = lib.map-attrs (pkg: pkgs-fun: defnix:
    (pkgs-fun defnix.config.system).${pkg}
  );
in lib.nix-exec.map (sets: (inherit-pkgs {
  gcc = sets.nixpkgs-8b9b0d9;

  libcxx = sets.nixpkgs-8b9b0d9;

  coreutils = sets.nixpkgs-499c510;

  bash = sets.nixpkgs-499c510;

  strongswan = sets.nixpkgs-499c510;

  kmod = sets.nixpkgs-499c510;

  openssl = sets.nixpkgs-499c510;

  patchelf = sets.nixpkgs-499c510;

  php = sets.nixpkgs-499c510;

  nginx = sets.nixpkgs-499c510;

  binutils = sets.nixpkgs-499c510;

  nixUnstable = sets.nixpkgs-8b9b0d9;

  boehmgc = sets.nixpkgs-8b9b0d9;

  gnupg = sets.nixpkgs-c8be814;

  nixopsUnstable = sets.nixpkgs-86055e2;

  openssh = sets.nixpkgs-8b9b0d9;
}) // {
  haskellPackages = inherit-pkgs {
    ghcPlain = haskellPackages sets.nixpkgs-c8be814;
  };
}) nixpkgs-sets
