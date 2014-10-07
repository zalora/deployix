lib: lib.composable [ "eval-support" "build-support" "pkgs" ] (

eval-support@{ calculate-id }:

build-support@{ compile-c, write-file }:

pkgs@{ coreutils }:

name: { filename, argv, envp ? null, user ? null }: let
  needs-envp = envp != null;

  exec-fun = if needs-envp
    then "execve(filename, argv, envp)"
    else "execv(filename, argv)";

  envp-def = if needs-envp then ''
    static char * envp[] = { ${lib.join ", " ((lib.map-attrs-to-list (name: value:
      ''"${name}=${value}"''
    ) envp) ++ [ "NULL" ])} };
  '' else "";

  setuid = if user == null
    then "0"
    else "setuid(${calculate-id user})";
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
    if (${setuid} == -1)
      err(213, "Setting user id");
    ${exec-fun};
    err(212, "executing %s", filename);
  }
''))
