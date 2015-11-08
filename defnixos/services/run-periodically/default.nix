deployix:

{ service-name
, prog
, hour
, min
, state-dir ? "/var/lib/${service-name}"
}: {
  start = deployix.pkgs.run-periodically {
    name = service-name;
    inherit prog hour min;
    state-file = "${state-dir}/periodic.state";
  };

  initializer = deployix.pkgs.execve "make-state-dir" {
    filename = "${deployix.pkgs.coreutils}/bin/mkdir";

    argv = [ "mkdir" "-p" state-dir ];
  };
}
