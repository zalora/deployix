lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ compile-c, write-file }:

pkgs@{ coreutils }:

name: { filename, argv, envp ? null }: let
  needs-envp = envp != null;

  exec-fun = if needs-envp
    then "execve(filename, argv, envp)"
    else "execv(filename, argv)";

  envp-def = if needs-envp then ''
    static char * envp[] = { ${lib.join ", " ((lib.map-attrs-to-list (name: value:
      ''"${name}=${value}"''
    ) envp) ++ [ "NULL" ])} };
  '' else "";
in compile-c [ "-Wl,-s" ] (write-file "${name}.c" ''
  #include <unistd.h>
  #include <err.h>

  static char * filename = "${filename}";

  /* TODO: Properly escape nix strings into C string literals */
  static char * argv[] = { ${lib.join ", " ((map (arg:
    ''"${arg}"''
  ) argv) ++ [ "NULL" ])} };

  ${envp-def}

  int main(int argc, char ** _argv) {
    ${exec-fun};
    err(212, "executing %s", filename);
  }
''))
