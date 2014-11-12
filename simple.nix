{ unsafe ? (builtins.getEnv "DEFNIX_UNSAFE") != ""
, system ? "x86_64-linux"
, pkgs ? import <nixpkgs> { inherit system; }
, ... }:

let
  inherit (import ./eval-support/unsafe.nix) shallow-fetchgit;

  nix-exec = ((if unsafe
      then import (shallow-fetchgit {
          url = "https://github.com/zalora/nixpkgs.git";
          branch = "defnix-nix-exec";
          clock = 3;
        })
      else import ((import pkgs.path {}).fetchgit {
          url = "git://github.com/NixOS/nixpkgs.git";
          rev = "c8be814f254311ca454844bdd34fd7206e801399";
          sha256 = "0db22de19145f6859b8e5b40e4904c81e5fe4b00a86fbe8db684e68c25d3c0dd";
        })
  ) {}).nix-exec;

  nix-exec-lib = import (nix-exec + "/share/nix/lib.nix");

  unsafe-perform-io = import (nix-exec + "/share/nix/unsafe-perform-io.nix");

in
unsafe-perform-io (import ./. nix-exec-lib { config.target-system = system; })
