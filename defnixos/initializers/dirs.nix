lib: lib.composable [ "pkgs" ] (

pkgs@{ coreutils, execve }:

# An initializer to create a directory

{ dir # The directory name
, mode ? "700" # The directory mode
}:

execve "create-${baseNameOf dir}" {
  filename = "${coreutils}/bin/mkdir";

  argv = [ "mkdir" "-p" dir "-m" mode ];

  envp = {};
})
