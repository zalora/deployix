#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
  for (char ** argv_iter = argv + 1; *argv_iter; ++argv_iter) {
    char * arg = *argv_iter;
    switch (arg[0]) {
      /* Handle escapes */
      case '\\':
        switch (arg[1]) {
          case '\\':
          case '@':
            *argv_iter = arg + 1;
            break;
        }
        break;
      case '@':
        *argv_iter = getenv(arg + 1);
        break;
    }
  }

  if (setenv("builder", argv[1], 1) == -1) {
    perror("Setting $builder");
    return 1;
  }

  execv(argv[1], argv + 1);
  fprintf(stderr, "Executing %s: %s", argv[1], strerror(errno));
  return 1;
}
