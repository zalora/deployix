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
  nixpkgs = system: import (fetchgit-bootstrap {
    url = "git://github.com/NixOS/nixpkgs.git";

    rev = "499c51016ef67bd0b158528dbff17ed6ecedd78b";

    sha256 = "8676c5d51578b7ff9208ef0613445f71a3841902a435f12d4af6d9ac23bea053";
  }) { inherit system; };

  composable-with-pkgs = f: lib.composable [ "build-support" ]
    (build-support@{ system }: f (nixpkgs system));

  inherit (builtins) getAttr;
in lib.composable-set {
  cc = composable-with-pkgs (pkgs: "${pkgs.gcc}/bin/cc");

  coreutils = composable-with-pkgs (getAttr "coreutils");

  sh = composable-with-pkgs (pkgs: "${pkgs.bash}/bin/bash");

  strongswan = composable-with-pkgs (getAttr "strongswan");

  kmod = composable-with-pkgs (getAttr "kmod");

  openssl = composable-with-pkgs (getAttr "openssl");
}
