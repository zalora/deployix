lib: lib.composable [ "eval-support" "build-support" "pkgs" ] (

eval-support@{ calculate-id, execve }:

prog: settings: if prog ? run-with-settings
  then prog.run-with-settings settings
  else execve prog.name {
    filename = prog;

    argv = [ prog.name ];

    inherit settings;
  })
