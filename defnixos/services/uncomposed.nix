lib: (lib.recursive-import ./.) // {
  # Run a service with the specified execve settings
  service-with-settings = defnix: service: settings: service // {
    start = defnix.pkgs.run-with-settings service.start settings;
  };

  # If `svc` has an initializer, run `init` after it. Otherwise, use `init`
  # as the initializer
  sequence-initializers = defnix: svc: init: svc // {
    initializer = if (svc.initializer or null) == null
      then init
      else defnix.pkgs.seq "${
        defnix.lib.hashless-basename svc.initializer
      }-and-${
        defnix.lib.hashless-basename init
      }" svc.initializer init;
  };
}
