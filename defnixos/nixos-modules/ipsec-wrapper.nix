{ config, lib, pkgs, ... }: let
  cfg = config.defnixos;

  defnix = import ../../.;

  inherit (lib) types mkOption mapAttrsToList;

  composed = defnix.compose {
    all.build-support.system = pkgs.system;
  };

  strongswan-service = cfg.strongswan-service { inherit (cfg) ca; outgoing-hosts = cfg.secure-upstreams; };

  nixos-configs = mapAttrsToList cfg.service-to-nixos-config (cfg.services //
    { strongswan = strongswan-service; });
in {
  options = {
    defnixos.strongswan-service = mkOption {
      description = "An already-composed strongswan defnixos service function";

      default = composed.defnixos.services.strongswan;

      type = types.uniq types.unspecified;
    };

    defnixos.service-to-nixos-config = mkOption {
      description = "An already-composed service-to-nixos-config defnixos library function";

      default = composed.defnixos.lib.service-to-nixos-config;

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

    defnixos.services = mkOption {
      default = {};

      type = types.uniq (types.attrsOf types.attrs);

      description = "Defnixos services to run on the machine.";
    };
  };

  config = {
    systemd.services = lib.fold (service: acc: service.systemd.services // acc)
      {} nixos-configs;
  };
}
