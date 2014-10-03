{ config, lib, pkgs, ... }: let
  cfg = config.defnixos;

  defnix = import ../../.;

  inherit (lib) types mkOption mapAttrsToList;

  composed = defnix.compose {
    all.build-support.system = pkgs.system;
  };

  hosts = lib.concatLists (mapAttrsToList (n: v: v.secure-upstreams)
    (lib.filterAttrs (n: v: v ? secure-upstreams) cfg.services));

  strongswan-service = cfg.strongswan-service { inherit (cfg) ca; outgoing-hosts = hosts; };

  nixos-configs = mapAttrsToList cfg.service-to-nixos-config (cfg.services //
    { strongswan = strongswan-service; });
in {
  options = {
    defnixos.strongswan-service = mkOption {
      description = "An already-composed strongswan defnixos service function";

      default = composed.defnixos.services.strongswan;
    };

    defnixos.service-to-nixos-config = mkOption {
      description = "An already-composed service-to-nixos-config defnixos library function";

      default = composed.defnixos.lib.service-to-nixos-config;
    };

    defnixos.ca = mkOption {
      description = "The CA used to authenticate ipsec connections";

      type = types.path;
    };

    defnixos.services = mkOption {
      default = {};

      type = types.attrsOf types.attrs;

      description = ''
        Defnixos services to run on the machine.

        In addition to the normal service attributes, services can
        have a `secure-upstreams` attribute specifying a list of hosts
        to set up on-demand outbound ipsec connections to.
      '';
    };
  };

  config = {
    systemd.services = lib.fold (service: acc: service.systemd.services // acc)
      {} nixos-configs;
  };
}
