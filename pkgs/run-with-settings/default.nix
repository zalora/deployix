deployix:

prog: settings: if prog ? run-with-settings
  then prog.run-with-settings settings
  else deployix.pkgs.execve prog.name {
    filename = prog;

    argv = [ prog.name ];

    inherit settings;
  }
