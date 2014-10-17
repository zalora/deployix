defnix:

{ name, prog, hour, min, state-file }:let
  inherit (defnix.build-support) compile-c serialize-c-value;

  inherit (defnix.pkgs) execve;

  run-periodically = compile-c [ "-Wl,-s" ] ./run-periodically.c;

  path = prog.outPath or prog;

  prog-name = prog.name or (baseNameOf prog);

  value = {
    hdr = {
      path_size = builtins.stringLength path + 1;

      prog_size = builtins.stringLength prog-name + 1;

      state_file_size = builtins.stringLength state-file + 1;

      inherit hour min;
    };

    path = ''"${path}"'';

    prog = ''"${prog-name}"'';

    state_file = ''"${state-file}"'';
  };

  arguments = serialize-c-value {
    name = "${name}-args";

    header = ./run-periodically.c;

    type = "settings(${
      toString value.hdr.path_size
    }, ${
      toString value.hdr.prog_size
    }, ${
      toString value.hdr.state_file_size
    })";

    inherit value;
  };
in if (hour < 0 || hour > 23 || min < 0 || min > 59)
  then throw "Hour or min out of range"
  else execve name {
    filename = run-periodically;

    argv = [ "run-periodically" arguments ];
  }
