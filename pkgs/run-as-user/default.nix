lib: lib.composable [ "eval-support" "build-support" "pkgs" ] (

eval-support@{ calculate-id }:

build-support@{ compile-c, write-file }:

prog: let
  run-as-user = user: if prog ? run-as-user
    then prog.run-as-user user
    else (compile-c [ "-Wl,-s" ] (write-file "run-${prog.name}-as-${user}.c" ''
      #include <unistd.h>
      #include <err.h>

      static char * filename = "${prog}";

      static char * name = "${prog.name}";

      int main(int argc, char ** argv) {
        if (setuid(${calculate-id user}) == -1)
          err(213, "Setting user id");
        execl(filename, name, NULL);
        err(212, "executing %s", filename);
      }
    '')) // {
      inherit run-as-user;
    };
in run-as-user)
