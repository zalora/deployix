lspawnib: let
  inherit (lib) nix-exec;

  inherit (nix-exec) sequence-attrs;

  inherit (nix-exec.builtins) fetchgit;

  make-upstream-nixpkgs-set = rev: nix-exec.map (src:
      let fn = import src; in system: fn { inherit system; }
    ) (fetchgit {
      url = "git://github.com/NixOS/nixpkgs.git";

      inherit rev;
    });

  /* Note! When updating nixpkgs, please only only update attribtues in
   * pkgs that you've actually tested, and keep the rest at the version of
   * nixpkgs they're currently using.
   *
   * Currently we are sticking with the 14.12 release branch unless we need
   * something from master
   */
  nixpkgs-sets = sequence-attrs {
    nixpkgs-986dfe1 =
      make-upstream-nixpkgs-set "986dfe15456012043a4c6e5538806560ddf98c80";

    nixpkgs-a2c1414 =
      make-upstream-nixpkgs-set "a2c14143e91bb76c69652b9a0bda15aca2b7fc62";
  };

  haskellPackages = pkgs-fun: system: (pkgs-fun system).haskellPackages;

  inherit-pkgs = lib.map-attrs (pkg: pkgs-fun: defnix:
    (pkgs-fun defnix.config.system).${pkg}
  );
in lib.nix-exec.map (sets: (inherit-pkgs {
  gcc = sets.nixpkgs-986dfe1;

  libcxx = sets.nixpkgs-986dfe1;

  coreutils = sets.nixpkgs-986dfe1;

  bash = sets.nixpkgs-986dfe1;

  strongswan = sets.nixpkgs-986dfe1;

  kmod = sets.nixpkgs-986dfe1;

  patchelf = sets.nixpkgs-986dfe1;

  php = sets.nixpkgs-986dfe1;

  nginx = sets.nixpkgs-986dfe1;

  binutils = sets.nixpkgs-986dfe1;

  nix = sets.nixpkgs-986dfe1;

  boehmgc = sets.nixpkgs-986dfe1;

  gnupg = sets.nixpkgs-986dfe1;

  openssh = sets.nixpkgs-986dfe1;

  diffutils = sets.nixpkgs-986dfe1;

  systemd = sets.nixpkgs-986dfe1;

  gnugrep = sets.nixpkgs-986dfe1;

  newrelic-sysmond = sets.nixpkgs-a2c1414;

  gnused = sets.nixpkgs-a2c1414;

  bashInteractive = sets.nixpkgs-a2c1414;

  utillinux = sets.nixpkgs-a2c1414;
}) // {
  haskellPackages = inherit-pkgs {
    ghcPlain = haskellPackages sets.nixpkgs-986dfe1;
  };
}) nixpkgs-sets
