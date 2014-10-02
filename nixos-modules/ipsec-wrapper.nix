{ config, lib, pkgs, ... }:
let
  cfg = config.defnixos;

  inherit (lib) types mkOption mapAttrsToList;

  pkgs-native-bootstrap = import pkgs.path {};

  pkgs-src = pkgs-native-bootstrap.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";
    rev = "0b23b5b141ec4262952ba6fb428cb5b6dc56e2a1";
    sha256 = "de38ae4bc3ffe57a6af54f9b851e56f1ae58e65681c676836b182597b130432c";
  };

  pkgs-default = import pkgs-src { inherit (pkgs) system; };

  defnix = import ../. { pkgs = pkgs-default; inherit (pkgs-default) system; };

  inherit (defnix) defnixos;

  hosts = lib.concatLists (mapAttrsToList (n: v: v.secure-upstreams)
    (lib.filterAttrs (n: v: v ? secure-upstreams) cfg.services));

  strongswan-service = defnixos.services.strongswan { inherit (cfg) ca; outgoing-hosts = hosts; };

  nixos-configs = mapAttrsToList defnixos.service-to-nixos-config (cfg.services //
    { strongswan = strongswan-service; });
in {
  options = {
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

    systemd.targets = lib.fold (service: acc: service.systemd.targets // acc)
      {} nixos-configs;
  };
}
