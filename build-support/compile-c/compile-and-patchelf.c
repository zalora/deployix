#include <sys/types.h>
#include <unistd.h>
#include <err.h>
#include <stdlib.h>

int main(int argc, char ** argv) {
  switch (vfork()) {
    case -1:
      err(1, "Forking to call " COMPILER);
    case 0:
      execv(COMPILER, argv);
      _exit(212);
  }

  int status;
  if (wait(&status) == -1)
    err(1, "Waiting for child");

  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
    exit(WEXITSTATUS(status));

  execl(PATCHELF, PATCHELF, "--shrink-rpath", getenv("out"), NULL);
  err(1, "Executing " PATCHELF);
}
