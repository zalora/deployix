#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>
#include <errno.h>
#include <signal.h>

int main(int argc, char ** argv) {
  while (*(++argv)) {
    char * filename = *argv;
    char * name = *(++argv);
    switch(vfork()) {
      case -1:
        err(214, "Forking to call %s", name);
      case 0:
        execl(filename, name, NULL);
        _exit(212);
    }
  }

  int status;
  while (wait(&status) != -1) {
    if (WIFEXITED(status)) {
      if (WEXITSTATUS(status) != 0)
        exit(WEXITSTATUS(status));
    } else {
      errno = 0;
      kill(getpid(), WTERMSIG(status));
      if (errno != 0)
        err(215, "Singalling self");
      else
        errx(215, "Didn't die when signalling self");
    }
  }
  if (errno != ECHILD)
    err(216, "Waiting for child");

  return 0;
}
