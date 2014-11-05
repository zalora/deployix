{ config, lib, pkgs, ... }: let
  cfg = config.defnixos;

  pkgs-native = import pkgs.path {};

  nix-exec = (import (pkgs-native.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";

    rev = "c8be814f254311ca454844bdd34fd7206e801399";

    sha256 = "0db22de19145f6859b8e5b40e4904c81e5fe4b00a86fbe8db684e68c25d3c0dd";
  }) {}).nix-exec;

  nix-exec-lib = import (nix-exec + "/share/nix/lib.nix");

  unsafe-perform-io = import (nix-exec + "/share/nix/unsafe-perform-io.nix");

  defnix = unsafe-perform-io (import ../../. nix-exec-lib { config.target-system = pkgs.system; });

  inherit (lib) types mkOption mapAttrsToList;

  strongswan-service = cfg.strongswan-service { inherit (cfg) ca; outgoing-hosts = cfg.secure-upstreams; };

  services = cfg.services // { strongswan = strongswan-service; };
in {
  options = {
    defnixos.strongswan-service = mkOption {
      description = "An already-composed strongswan defnixos service function";

      default = cfg.defnix.defnixos.services.strongswan;

      type = types.uniq types.unspecified;
    };

    defnixos.services-to-nixos-config = mkOption {
      description = "An already-composed services-to-nixos-config defnixos library function";

      default = cfg.defnix.defnixos.nixos-wrappers.services-to-nixos-config;

      type = types.uniq types.unspecified;
    };

    defnixos.ca = mkOption {
      description = "The CA used to authenticate ipsec connections";

      type = types.uniq types.path;
    };

    defnixos.secure-upstreams = mkOption {
      description = "Upstreams this machine needs access to over ipsec";

      default = [];

      type = types.uniq (types.listOf types.str);
    };

    defnixos.users = mkOption {
      description = "Usernames used by defnixos services";

      default = [];

      type = types.uniq (types.listOf types.str);
    };

    defnixos.services = mkOption {
      default = {};

      type = types.uniq (types.attrsOf types.attrs);

      description = "Defnixos services to run on the machine.";
    };

    defnixos.defnix = mkOption {
      default = defnix;

      type = types.uniq types.attrs;

      description = "The composed defnix set to use.";
    };
  };

  config = {
    inherit (cfg.services-to-nixos-config services) systemd;

    users.extraUsers = builtins.listToAttrs (map (name: {
      inherit name;
      value.uid = cfg.defnix.eval-support.calculate-id name;
    }) cfg.users);
  };
}
