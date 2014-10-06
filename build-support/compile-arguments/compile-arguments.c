#include <unistd.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

static void write_full(const void * buf, size_t sz) {
tail_call: ;
  ssize_t written = write(3, buf, sz);
  if (written == -1)
    err(1, "writing to stdout");
  else {
    sz -= written;
    buf += written;

    if (sz)
      goto tail_call;
    else
      return;
  }
}

int main(int argc, char ** argv) {
  int fd = open(getenv("out"), O_WRONLY | O_CREAT, 0755);
  if (fd == -1)
    err(1, "opening %s", getenv("out"));

  while(*(++argv)) {
    char * arg_type = *argv;
    char * arg = *(++argv);

    if (strcmp(arg_type, "string") == 0 || strcmp(arg_type, "path") == 0) {
      size_t arg_size = strlen(arg) + 1;

      write_full(&arg_size, sizeof arg_size);
      write_full(arg, arg_size);
    } else if (strcmp(arg_type, "int") == 0) {
      /* nix ints are actually long */
      long arg_val = strtol(arg, NULL, 0);

      write_full(&arg_val, sizeof arg_val);
    } else if (strcmp(arg_type, "bool") == 0) {
      bool arg_val;

      if (strcmp(arg, "1") == 0)
        arg_val = true;
      else if (strcmp(arg, "") == 0)
        arg_val = false;
      else
        errx(1, "invalid boolean value %s", arg);

      write_full(&arg_val, sizeof arg_val);
    } else
      errx(1, "Invalid argument type %s", arg_type);
  }
}
