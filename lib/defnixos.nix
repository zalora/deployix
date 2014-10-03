lib: {
  # Convert a defnixos service into a nixos config set
  service-to-nixos-config = name: service-config: let
    # !!! TODO: Actually handle escapes
    systemd-escape = x: x;

    activation-services = builtins.listToAttrs (lib.imap (idx: activation-config: {
      name = "${name}-activation-${toString idx}";

      value = {
        description = activation-config.description or "A ${name} activation";

        serviceConfig.ExecStart =
          lib.join " " (map systemd-escape activation-config.run);

        serviceConfig.Type = "oneshot";

        serviceConfig.RemainAfterExit = true;
      };
    }) (service-config.activations or []));

    config = {
      systemd.services = activation-services // {
        ${name} = {
          description = service-config.description or "${name} service";

          requires = [ "${name}-activations.target" ];

          after = [ "${name}-activations.target" ];

          serviceConfig.ExecStart =
            lib.join " " (map systemd-escape service-config.start);

          environment = {
            _type = "override";

            content = service-config.environment or {};

            priority = 50;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };

      systemd.targets."${name}-activations" = let
        service-names =
          map (x: "${x}.service") (builtins.attrNames activation-services);
      in {
        description = "Activations for ${name}";

        requires = service-names;

        after = service-names;
      };
    };
  in config;
}
