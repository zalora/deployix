#define _GNU_SOURCE
#include <sys/types.h>
#include <unistd.h>
#include <err.h>
#include <stdlib.h>
#include <sys/wait.h>

int main(int argc, char ** argv) {
  switch (vfork()) {
    case -1:
      err(1, "Forking to call " COMPILER);
    case 0:
      execv(COMPILER, argv);
      _exit(212);
  }

  int status;
  while (wait(&status) == -1);

  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
    exit(WEXITSTATUS(status));

  char * out = getenv("out");

  switch (vfork()) {
    case -1:
      err(1, "Forking to call " STRIP);
    case 0:
      execl(STRIP, "strip", "--strip-all", out, NULL);
      _exit(212);
  }

  while (wait(&status) == -1);

  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
    exit(WEXITSTATUS(status));

  execl(PATCHELF, "patchelf", "--shrink-rpath", out, NULL);
  err(1, "Executing " PATCHELF);
}
