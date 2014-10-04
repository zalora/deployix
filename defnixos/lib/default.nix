lib: lib.composable-set {
  # Convert a defnixos service into a nixos config set
  service-to-nixos-config = lib.composable [ "build-support" "pkgs" ] (
    build-support@{ write-script }:

    pkgs@{ coreutils, sh }:

    name: service-config@{ start, initializers ? [] }: let
      run = "#!${sh} -e\n" + (lib.join "\n" (map (initializer:
        "(${initializer} || ${coreutils}/bin/kill $$) &"
      ) initializers)) + "\nwait\n${start}";

      config = {
        systemd.services.${name} = {
          description = "${name} service";

          serviceConfig.ExecStart = write-script "${name}-exec" run;

          wantedBy = [ "multi-user.target" ];
        };
      };
    in config
  );
}
