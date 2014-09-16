#define _GNU_SOURCE
#include <linux/sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, char ** argv) {
  if (unshare(CLONE_NEWNS) == -1) {
    perror("Entering mount namespace");
    return 1;
  }

  if (setenv("builder", argv[1], 1) == -1) {
    perror("Setting $builder");
    return 1;
  }

  execv(argv[1], argv + 1);
  fprintf(stderr, "Executing %s: %s", argv[1], strerror(errno));
  return 1;
}
