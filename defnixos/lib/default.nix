lib: lib.composable-set {
  # Convert a defnixos service into a nixos config set
  service-to-nixos-config = lib.composable [ "build-support" "pkgs" ] (
    build-support@{ write-script }:

    pkgs@{ coreutils, sh }:

    name: service-config: let
      # !!! TODO: Actually handle escapes
      shell-escape = x: x;

      run = "#!${sh} -e\n" + (lib.join "\n" (map ({ run, ... }:
        "(${lib.join " " (map shell-escape run)} || ${coreutils}/bin/kill $$) &"
      ) (service-config.initializers or []))) + "\nwait\n" + (lib.join " " (
        map shell-escape service-config.start
      ));

      config = {
        systemd.services.${name} = {
          description = service-config.description or "${name} service";

          serviceConfig.ExecStart = write-script "${name}-exec" run;

          environment = {
            _type = "override";

            content = service-config.environment or {};

            priority = 50;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
    in config
  );
}
