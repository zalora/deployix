defnix:

prog: settings: if prog ? run-with-settings
  then prog.run-with-settings settings
  else defnix.pkgs.execve prog.name {
    filename = prog;

    argv = [ prog.name ];

    inherit settings;
  }
