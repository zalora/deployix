lib: (lib.recursive-import ./.) // {
  # Run a service with the specified execve settings
  service-with-settings = defnix: service: settings: service // {
    start = defnix.pkgs.run-with-settings service.start settings;
  };
}
