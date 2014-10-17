defnix:

{ service-name
, prog
, hour
, min
, state-dir ? "/var/lib/${service-name}"
}: {
  start = defnix.pkgs.run-periodically {
    name = service-name;
    inherit prog hour min;
    state-file = "${state-dir}/periodic.state";
  };

  initializer = defnix.pkgs.execve "make-state-dir" {
    filename = "${defnix.pkgs.coreutils}/bin/mkdir";

    argv = [ "mkdir" "-p" state-dir ];
  };
}
