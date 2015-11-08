deployix:

{ port ? 80 # Port to listen on
, config # Configuration file, should only listen on [::]:${port} with ipv6only=off
, prefix ? "/var/lib/nginx"  # nginx prefix (temp files etc. live here by default)
, log-dir ? "/var/log/nginx" # nginx default log dir
}: let
  inherit (deployix.build-support) write-script;

  inherit (deployix.defnixos.activations) socket;

  inherit (deployix.pkgs) multiplex-activations execve nginx sh;
in {
  start = multiplex-activations [ (socket {
    family = deployix.lib.socket-address-families.AF_INET6;

    inherit port;
  }) ] (execve "start-nginx-${toString port}" {
    filename = "${nginx}/bin/nginx";

    argv = [ "nginx" "-c" config "-p" prefix ];

    envp = {
      NGINX = "3;";
    };
  });

  on-demand = true;

  initializer = write-script "setup-nginx-dirs" ''
    #!${sh} -e
    mkdir -p ${prefix} -m 700
    mkdir -p ${log-dir} -m 700
    ln -svfT ${log-dir} ${prefix}/logs
  '';
}
