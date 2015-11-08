{ config, lib, pkgs, ... }: let
  cfg = config.defnixos;

  pkgs-native = import pkgs.path {};

  nix-exec = (import (pkgs-native.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";

    rev = "7ec072acd8dc7126149d059d92dfcd5af7244b50";

    sha256 = "9c7fbfc93edb98a67ae585087f4a67b16061994a87f6c90ff4ce8fc7a79f947c";
  }) {}).nix-exec;

  nix-exec-lib = import (nix-exec + "/share/nix/lib.nix") unsafe-perform-io;

  unsafe-perform-io = import (nix-exec + "/share/nix/unsafe-perform-io.nix");

  deployix = unsafe-perform-io (import ../../. nix-exec-lib { config.system = pkgs.system; });

  inherit (lib) types mkOption mapAttrsToList;

  strongswan-service = cfg.strongswan-service { inherit (cfg) ca cert-archive; outgoing-hosts = cfg.secure-upstreams; };

  services = cfg.services // { strongswan = strongswan-service; };
in {
  options = {
    defnixos.strongswan-service = mkOption {
      description = "An already-composed strongswan defnixos service function";

      default = cfg.deployix.defnixos.services.strongswan;

      type = types.uniq types.unspecified;
    };

    defnixos.services-to-nixos-config = mkOption {
      description = "An already-composed services-to-nixos-config defnixos library function";

      default = cfg.deployix.defnixos.nixos-wrappers.services-to-nixos-config;

      type = types.uniq types.unspecified;
    };

    defnixos.ca = mkOption {
      description = "The CA used to authenticate ipsec connections";

      type = types.uniq types.path;
    };

    defnixos.cert-archive = mkOption {
      description = "The certificate archive containing a keypair signed by the CA";

      default = null;

      type = types.uniq (types.nullOr types.path);
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

    defnixos.deployix = mkOption {
      default = deployix;

      type = types.uniq types.attrs;

      description = "The composed deployix set to use.";
    };
  };

  config = {
    inherit (cfg.services-to-nixos-config services) systemd;

    users.extraUsers = builtins.listToAttrs (map (name: {
      inherit name;
      value.uid = cfg.deployix.eval-support.calculate-id name;
    }) cfg.users);
  };
}
