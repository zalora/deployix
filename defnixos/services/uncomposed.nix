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

  # Create a new user and run the service as that user
  run-as-user = defnix: let
    inherit (defnix.defnixos) services;
  in user-spec@{ name, comment }: svc:
    services.sequence-initializers (services.service-with-settings svc {
      user = name;

      group = "nogroup";
    }) (defnix.pkgs.add-user user-spec);
}
