{ config, lib, pkgs, ... }: let
  cfg = config.defnixos;

  defnix = import ../.;

  inherit (defnix) defnixos build-support;

  inherit (lib) types mkOption mapAttrsToList;

  service-to-nixos-config = defnixos.service-to-nixos-config {
    inherit (lib) imap concatStringsSep mkForce;
  };

  pkgs-native-bootstrap = import pkgs.path {};

  pkgs-src = pkgs-native-bootstrap.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";
    rev = "0b23b5b141ec4262952ba6fb428cb5b6dc56e2a1";
    sha256 = "de38ae4bc3ffe57a6af54f9b851e56f1ae58e65681c676836b182597b130432c";
  };

  pkgs-native = import pkgs-src {};

  pkgs-default = import pkgs-src { inherit (pkgs) system; };

  output-to-argument = build-support.output-to-argument {
    inherit (pkgs-native) runCommand;
  };

  compile-c = build-support.compile-c {
    inherit output-to-argument;
    # Theoretically we could use pkgs-native and a cross-compiler...
    cc = "${pkgs-default.gcc}/bin/gcc";
    inherit (pkgs-default) system coreutils;
  };

  wait-for-file = defnix.wait-for-file { inherit compile-c; };

  certs-activation = defnixos.activations.certs {
    inherit (cfg.strongswan-packages) openssl wait-for-file bash;
    inherit (pkgs-native) writeScript;
  };

  strongswan-service-fn = defnixos.services.strongswan {
    inherit certs-activation;

    inherit (cfg.strongswan-packages) strongswan kmod;

    inherit (lib) imap;
  };

  hosts = lib.concatLists (mapAttrsToList (n: v: v.secure-upstreams)
    (lib.filterAttrs (n: v: v ? secure-upstreams) cfg.services));

  strongswan-service = strongswan-service-fn { inherit (cfg) ca; outgoing-hosts = hosts; };

  nixos-configs = mapAttrsToList service-to-nixos-config (cfg.services //
    { strongswan = strongswan-service; });
in {
  options = {
    defnixos.strongswan-packages = {
      kmod = mkOption {
        description = "The kmod package to use for strongswan";

        default = pkgs-default.kmod;

        type = types.package;
      };

      strongswan = mkOption {
        description = "The strongswan package to use for strongswan";

        default = pkgs-default.strongswan;

        type = types.package;
      };

      openssl = mkOption {
        description = "The openssl package to use for strongswan activation";

        default = pkgs-default.openssl;

        type = types.package;
      };

      bash = mkOption {
        description = "The bash package to use for strongswan activation";

        default = pkgs-default.bash;

        type = types.package;
      };

      wait-for-file = mkOption {
        description = "The wait-for-file program to use for strongswan activation";

        default = wait-for-file;

        type = types.package;
      };
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

    systemd.targets = lib.fold (service: acc: service.systemd.targets // acc)
      {} nixos-configs;
  };
}
