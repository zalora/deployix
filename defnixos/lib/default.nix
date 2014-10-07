lib: lib.composable-set {
  # Convert a set of defnixos services into a nixos config set
  services-to-nixos-config = lib.composable [ "build-support" "pkgs" ] (
    build-support@{ write-script }:

    pkgs@{ coreutils, sh, notify-readiness }:

    services: let
      make-regular-systemd-service = name: { start, initializer }: let
        run = ''
          #!${sh} -e
          ${toString initializer}
          mkdir -p /run/defnixos-services/${name}
          cd /run/defnixos-services/${name}
          exec ${start}
        '';

        value = {
          description = "${name} service";

          serviceConfig.ExecStart = write-script "${name}-exec" run;

          wantedBy = [ "defnixos.target" ];
        };
      in { inherit name value; };

      make-on-demand-systemd-services = name: { start, initializer }: let
        listen-run = ''
          #!${sh} -e
          ${toString initializer}
          mkdir -p /run/defnixos-services/${name}
          cd /run/defnixos-services/${name}
          exec ${start}
        '';

        listen-service = {
          description = "${name} on-demand service";

          serviceConfig.ExecStart = write-script "${name}-listen" listen-run;

          serviceConfig.Type = "notify";

          wantedBy = [ "on-demand.target" ];

          before = [ "on-demand.target" ];
        };

        ready-service = {
          description = "${name} readiness notification";

          serviceConfig.ExecStart = notify-readiness;

          serviceConfig.WorkingDirectory = "/run/defnixos-services/${name}";

          serviceConfig.Type = "oneshot";

          serviceConfig.RemainAfterExit = true;

          unitConfig.BindsTo = [ "${name}.service" ];

          after = [ "${name}.service" ];

          wantedBy = [ "defnixos.target" ];
        };
      in [
        { inherit name; value = listen-service; }
        { name = "${name}-ready"; value = ready-service; }
      ];

      make-systemd-services =
        name: { start, initializer ? null, on-demand ? false }: let
          service-config = { inherit start initializer; };
        in if on-demand
            then make-on-demand-systemd-services name service-config
            else [ (make-regular-systemd-service name service-config) ];
    in {
      systemd.services = builtins.listToAttrs (builtins.concatLists (
        lib.map-attrs-to-list make-systemd-services services
      ));

      systemd.targets = {
        defnixos = {
          description = "defnixos services";

          unitConfig.X-StopOnReconfiguration = true;
        };

        on-demand = {
          description = "on-demand defnixos services";

          wants = [ "defnixos.target" ];

          before = [ "defnixos.target" ];

          wantedBy = [ "multi-user.target" ];

          unitConfig.X-StopOnReconfiguration = true;
        };
      };
    }
  );
}
