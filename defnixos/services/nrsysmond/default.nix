deployix: let
  inherit (deployix.pkgs) newrelic-sysmond execve coreutils;
in { config, log-dir ? "/var/log/newrelic" }: {
  start = execve "nrsysmond-exec" {
    filename = "${newrelic-sysmond}/bin/nrsysmond";

    argv = [ "nrsysmond" "-c" config "-f" ];
  };

  initializer = execve "mkdir-nrsysmond" {
    filename = "${coreutils}/bin/mkdir";

    argv = [ "mkdir" "-p" log-dir ];
  };
}
