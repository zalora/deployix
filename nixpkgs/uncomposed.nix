lib: let
  fetchgit-bootstrap = import ./fetchgit-bootstrap.nix;

  /* Note! When updating nixpkgs, please only only update attribtues in
   * pkgs that you've actually tested, and keep the rest at the version of
   * nixpkgs they're currently using
   */
  nixpkgs-499c510 = system: import (fetchgit-bootstrap {
    url = "git://github.com/NixOS/nixpkgs.git";

    rev = "499c51016ef67bd0b158528dbff17ed6ecedd78b";

    sha256 = "8676c5d51578b7ff9208ef0613445f71a3841902a435f12d4af6d9ac23bea053";
  }) { inherit system; };

  haskellPackages-499c510 = system: (nixpkgs-499c510 system).haskellPackages;

  inherit-pkgs = lib.map-attrs (pkg: pkgs-fun: defnix:
    (pkgs-fun defnix.config.target-system).${pkg}
  );
in (inherit-pkgs {
  gcc = nixpkgs-499c510;

  coreutils = nixpkgs-499c510;

  bash = nixpkgs-499c510;

  strongswan = nixpkgs-499c510;

  kmod = nixpkgs-499c510;

  openssl = nixpkgs-499c510;

  patchelf = nixpkgs-499c510;

  php = nixpkgs-499c510;

  nginx = nixpkgs-499c510;

  binutils = nixpkgs-499c510;
}) // {
  haskellPackages = inherit-pkgs {
    ghcPlain = haskellPackages-499c510;
  };
}
