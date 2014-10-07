lib: lib.composable [ "pkgs" ] (

pkgs@{ run-with-settings }:

service: settings: service // {
  start = run-with-settings service.start settings;
})
