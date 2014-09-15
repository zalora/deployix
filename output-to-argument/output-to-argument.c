#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, char ** argv) {
  if (argc < 3) {
    fprintf(stderr, "Usage: %s PROG ARG [ARG...]\n", argv[0]);
    return 1;
	}

  for (char ** argv_iter = argv + 2; *argv_iter; ++argv_iter) {
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
        if (!*argv_iter) {
          fprintf(stderr, "Argument %s not found in the environment, is it an output?\n", arg + 1);
          return 1;
        }
        break;
    }
  }

  execvp(argv[1], argv + 2);
  fprintf(stderr, "Executing %s: %s", argv[1], strerror(errno));
  return 1;
}
