lib: (lib.recursive-import ./.) // {
  # Run a service with the specified execve settings
  service-with-settings = deployix: service: settings: service // {
    start = deployix.pkgs.run-with-settings service.start settings;
  };

  # If `svc` has an initializer, run `init` after it. Otherwise, use `init`
  # as the initializer
  sequence-initializers = deployix: svc: init: svc // {
    initializer = if (svc.initializer or null) == null
      then init
      else deployix.pkgs.seq "${
        deployix.lib.hashless-basename svc.initializer
      }-and-${
        deployix.lib.hashless-basename init
      }" svc.initializer init;
  };
}
