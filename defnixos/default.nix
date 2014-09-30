lib:

rec {
  services-dir = ./services;

  service-to-nixos-module = name: service-config: let
    # !!! TODO: Actually handle escapes
    systemd-escape = x: x;

    activation-services = builtins.listToAttrs (lib.imap (idx: activation-config: {
      name = "${name}-activation-${idx}";

      value = {
        inherit (activation-config) description;

        serviceConfig.ExecStart =
          lib.concatStringsSep " " (map systemd-escape activation-config.run);

        serviceConfig.Type = "oneshot";

        serviceConfig.RemainAfterExit = true;
      };
    }) (service-config.activations or []));

    config = {
      systemd.services = activation-services // {
        ${name} = {
          inherit (service-config) description;

          requires = [ "${name}-activations.target" ];

          after = [ "${name}-activations.target" ];

          serviceConfig.ExecStart =
            lib.concatStringsSep " " (map systemd-escape service-config.start);
        };
      };

      systemd.targets."${name}-activations" = {
        requires = builtins.attrNames activation-services;

        after = builtins.attrNames activation-services;
      };
    };
  in { ... }: { inherit config; };
}
