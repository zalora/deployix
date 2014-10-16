defnix:

{ name, header ? null, type, value, flags ? [] }:  let
  inherit (defnix.lib) join map-attrs-to-list imap;

  inherit (defnix.config) target-system;

  inherit (defnix.build-support) write-file compile-c;

  value-to-assignment = value: let type = builtins.typeOf value; in
    if (value.type or null) == "derivation" || type == "path"
      then ''"${value}"''
    else if type == "set"
      then "{ " + (join ", " (map-attrs-to-list (name: value:
        ".${name} = ${value-to-assignment value}"
      ) value)) + " }"
    else if type == "list"
      then "{ " + (join ", " (map value-to-assignment value)) + " }"
    else if type == "bool"
      then if value then "1" else "0"
    else if type == "int"
      then "${toString value}L"
    else value;

  c = defnix.build-support.write-file "write-${name}.c" ''
    #define _GNU_SOURCE
    #include <unistd.h>
    #include <err.h>
    #include <stdlib.h>
    #include <string.h>
    #include <fcntl.h>
    #define DEFNIX_TYPES_ONLY
    ${if header != null then "#include \"${header}\"" else ""}

    static void write_full(int out_fd, const void * buf, size_t sz) {
      ssize_t written = write(out_fd, buf, sz);
      if (written == -1)
        err(1, "writing to %s", getenv("out"));
      else {
        sz -= written;
        buf += written;

        if (sz)
          return write_full(out_fd, buf, sz);
        else
          return;
      }
    }

    static const ${type} val = ${value-to-assignment value};

    int main(int argc, char ** argv) {
      int out_fd = open(getenv("out"), O_WRONLY | O_CREAT, 0644);
      write_full(out_fd, &val, sizeof val);
      return 0;
    }
  '';
in derivation {
  inherit name;

  builder = compile-c flags c;

  system = target-system;
}
