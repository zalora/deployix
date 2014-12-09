#define _GNU_SOURCE
#include <fcntl.h>
#include <sys/socket.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <setjmp.h>
#include <signal.h>
#include <err.h>
#include <stdlib.h>

static void wait_for_children() {
	while (1) {
		int status;
		pid_t child = waitpid(-1, &status, WNOHANG);
		if (!child || child == -1)
			return;

		if (WIFEXITED(status)) {
			int code = WEXITSTATUS(status);
			if (code)
				fprintf(stderr, "child process %ld exited with non-zero code %d\n", (long) child, code);
		} else {
			fprintf(stderr, "child process %ld killed by signal %s\n", (long) child, strsignal(WTERMSIG(status)));
		}
	}
}

static sigjmp_buf env;

static void handle_term(int sig) {
	siglongjmp(env, 1);
}

int main(int argc, char ** argv) {
	setpgid(0, 0);

	sigset_t set, oldset;
	sigemptyset(&set);
	sigaddset(&set, SIGTERM);
	sigprocmask(SIG_BLOCK, &set, &oldset);
	if (sigsetjmp(env, 1) == 1) {
		kill(0, SIGTERM);
		exit(0);
	}
	sigprocmask(SIG_SETMASK, &oldset, NULL);

	struct sigaction act;
	memset(&act, 0, sizeof act);
	act.sa_handler = &handle_term;
	sigaction(SIGTERM, &act, NULL);

	fcntl(3, F_SETFD, fcntl(3, F_GETFD) | FD_CLOEXEC);

	while (1) {
		wait_for_children();

		int conn = accept(3, NULL, NULL);

		if (conn == -1) {
			if (errno == EINTR)
				continue;
			err(1, "accepting socket connection");
		}

		errno = 0;
		while (dup2(conn, STDIN_FILENO) == -1 && errno == EINTR);
		if (errno && errno != EINTR)
			err(2, "duping socket to stdin");
		while (dup2(conn, STDOUT_FILENO) == -1 && errno == EINTR);
		if (errno && errno != EINTR)
			err(2, "duping socket to stout");

		switch (vfork()) {
			case -1:
				err(3, "forking");
			case 0:
				execl(argv[2], argv[1], NULL);
				_exit(212);
		}

		if (close(conn) == -1)
			perror("closing socket connection");
	}
}
