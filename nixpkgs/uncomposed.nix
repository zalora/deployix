lib: let
  nix-deps = import <nix/config.nix>;

  fetchgit-bootstrap = { url, rev, sha256 }: derivation {
    name = "git-export";

    builder = nix-deps.shell;

    args = [ "-e" "-c" "eval \"$script\"" ];

    system = builtins.currentSystem;

    PATH = builtins.getEnv "PATH";

    script = ''
      mkdir $out
      mkdir download
      cd download
      git clone ${url}
      cd *
      git archive --format=tar ${rev} | tar -x -C $out
      rm $out/.gitignore
    '';

    impureEnvVars = [
      "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
    ];

    preferLocalBuild = true;

    outputHashAlgo = "sha256";

    outputHash = sha256;

    outputHashMode = "recursive";
  };

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
    (pkgs-fun (defnix.config.target-system or builtins.currentSystem)).${pkg}
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
}) // {
  haskellPackages = inherit-pkgs {
    ghcPlain = haskellPackages-499c510;
  };
}
