defnix:

name: let
  inherit (defnix.lib) join map-attrs-to-list restart-modes;

  inherit (defnix.eval-support) calculate-id;

  inherit (defnix.build-support) compile-c write-file;

  self = args@{ filename, argv, envp ? null, settings ? {} }: let
    user = settings.user or null;

    group = settings.group or null;

    working-directory = settings.working-directory or null;

    restart = settings.restart or restart-modes.no;

    needs-envp = envp != null;

    exec-fun = if needs-envp
      then "execve(filename, argv, envp)"
      else "execv(filename, argv)";

    envp-def = if needs-envp then ''
      static char * envp[] = { ${join ", " ((map-attrs-to-list (name: value:
        ''"${name}=${value}"''
      ) envp) ++ [ "NULL" ])} };
    '' else "";

    setuid = if user == null
      then "0"
      else "setuid(${toString (calculate-id user)})";

    setgid = if group == null
      then "0"
      else "setgid(${toString (calculate-id group)})";

    chdir = if working-directory == null
      then "0"
      else "chdir(\"${working-directory}\")"

    setup-mounts = join ";\n" (map-attrs-to-list (dest: source:
      if builtins.substring 0 1 dest == "/" then ''
        {
          /* We need to ensure we're not mounting inside of a shared mount */
          char dest[sizeof "${dest}"];
          memmove(dest, "${dest}", sizeof dest);
          size_t chars_left = sizeof dest - 1;
          while (mount(0, dest, 0, MS_PRIVATE, 0) == -1) {
            char * slash = (char *) memrchr(dest, '/', chars_left);
            while (slash != dest && *(slash - 1) == '/')
              --slash;
            if (slash == dest) {
              mount(0, "/", 0, MS_PRIVATE, 0);
              break;
            }
            chars_left = (slash - dest) - 1;
            *slash = '\0';
          }
        }
        if (mount("${source}", "${dest}", NULL, MS_BIND, NULL) == -1)
          err(214, "binding ${source} to ${dest}")
      '' else throw "${dest} is not an absolute path"
    ) (settings.bind-mounts or {}));

    unshare = if (settings.bind-mounts or {}) == {}
      then "0"
      else "unshare(CLONE_NEWNS)";

    fork = if restart == restart-modes.no
      then ""
      else ''
        again:
          switch (vfork()) {
            case -1:
              err(212, "forking to execute %s", filename);
            case 0:
              break;
            default: {
              int status;
              while(wait(&status) == -1);
              goto again;
            }
          }
      '';
  in (compile-c [] (write-file "${name}.c" ''
    #define _GNU_SOURCE
    #include <sys/wait.h>
    #include <errno.h>
    #include <unistd.h>
    #include <err.h>
    #include <sched.h>
    #include <sys/mount.h>
    #include <string.h>

    static char * filename = "${filename}";

    /* TODO: Properly escape nix strings into C string literals */
    static char * argv[] = { ${join ", " ((map (arg:
      ''"${arg}"''
    ) argv) ++ [ "NULL" ])} };

    ${envp-def}

    int main(int argc, char ** _argv) {
      if (${unshare} == -1)
        err(214, "unsharing parent execution context");
      ${setup-mounts};
      if (${chdir} == -1)
        err(215, "Changing working directory");
      /* Always drop perms last! */
      if (${setgid} == -1)
        err(213, "Setting group id");
      if (${setuid} == -1)
        err(213, "Setting user id");
      ${fork}
      ${exec-fun};
      err(212, "executing %s", filename);
    }
  '')) // {
    run-with-settings = new-settings: self (args // {
      settings = settings // new-settings // {
        bind-mounts = (settings.bind-mounts or {}) //
          (new-settings.bind-mounts or {});
      };
    });

    inherit settings;
  };
in self
