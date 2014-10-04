lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ compile-c, write-file }:

pkgs@{ coreutils }:

name: filename: argv: envp: compile-c [ "-Wl,-s" ] (write-file "${name}.c" ''
  #include <unistd.h>
  #include <err.h>

  static char * filename = "${filename}";

  /* TODO: Properly escape nix strings into C string literals */
  static char * argv[] = { ${lib.join ", " ((map (arg:
    ''"${arg}"''
  ) argv) ++ [ "NULL" ])} };

  static char * envp[] = { ${lib.join ", " ((lib.map-attrs-to-list (name: value:
    ''"${name}=${value}"''
  ) envp) ++ [ "NULL" ])} };

  int main(int argc, char ** _argv) {
    execve(filename, argv, envp);
    err(212, "executing %s", filename);
  }
''))
