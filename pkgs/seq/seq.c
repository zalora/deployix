#define _GNU_SOURCE

#include <string.h>
#include <unistd.h>
#include <err.h>
#include <sys/wait.h>
#include <stdio.h>
#include <signal.h>

int main(int argc, char ** argv) {
	const char * name = strrchr(*++argv, '/');
	if (!name)
		name = *argv;
	else
		name += 1;
	switch (vfork()) {
		case -1:
			err(1, "forking");
		case 0:
			execl(*argv, name, NULL);
			_exit(212);
	}
	int status;
	while (wait(&status) == -1);
	if (WIFEXITED(status)) {
		int code = WEXITSTATUS(status);
		if (code)
			errx(code, "%s exited with non-zero code %i", name,
					code);
	} else {
		int sig = WTERMSIG(status);
		fprintf(stderr, "%s killed by signal %s", name, strsignal(sig));
		kill(getpid(), sig);
	}

	name = strrchr(*++argv, '/');
	if (!name)
		name = *argv;
	else
		name += 1;
	execl(*argv, name, NULL);
	err(212, "executing %s", name);
}
