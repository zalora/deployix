#ifndef DEFNIX_TYPES_ONLY
#define _GNU_SOURCE
#endif

#include <stddef.h>

struct settings_header {
  size_t path_size;
  size_t prog_size;
  size_t state_file_size;
  int hour;
  int min;
};

#define settings(path_sz, prog_sz, sf_sz) \
  struct { \
    struct settings_header hdr; \
    char path[(path_sz)]; \
    char prog[(prog_sz)]; \
    char state_file[(sf_sz)]; \
  }

#ifndef DEFNIX_TYPES_ONLY
#include <time.h>
#include <fcntl.h>
#include <err.h>
#include <unistd.h>
#include <sys/mman.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/select.h>
#include <errno.h>
#include <setjmp.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/stat.h>

static void loop(struct settings_header * hdr, time_t * last_run)
  __attribute__ ((noreturn));

int main(int argc, char ** argv) {
  int settings_fd = open(argv[1], O_RDONLY);
  if (settings_fd == -1)
    err(1, "opening %s", argv[1]);

  struct stat st;
  if (fstat(settings_fd, &st) == -1)
    err(1, "statting %s", argv[1]);

  struct settings_header * hdr = (struct settings_header *)
    mmap( NULL
        , st.st_size
        , PROT_READ | PROT_WRITE
        , MAP_PRIVATE
        , settings_fd
        , 0
        );

  if (hdr == MAP_FAILED)
    err(1, "mapping %s into memory", argv[1]);

  if (close(settings_fd) == -1)
    err(1, "closing %s", argv[1]);

  typedef settings(hdr->path_size, hdr->prog_size, hdr->state_file_size) settings_t;
  settings_t * set = (settings_t *) hdr;

  int state_file_fd = open(set->state_file, O_RDWR | O_CLOEXEC | O_CREAT, 0644);
  if (state_file_fd == -1)
    err(1, "opening state file %s", set->state_file);

  time_t * last_run;

  if (ftruncate(state_file_fd, sizeof *last_run) == -1)
    err(1, "sizing state file %s", set->state_file);

  last_run = (time_t *) mmap( NULL
                            , sizeof *last_run
                            , PROT_READ | PROT_WRITE, MAP_SHARED
                            , state_file_fd
                            , 0
                            );

  if (last_run == MAP_FAILED)
    err(1, "mapping %s into memory", set->state_file);

  if (close(state_file_fd) == -1)
    err(1, "closing %s", set->state_file);

  loop(hdr, last_run);
}

static sigjmp_buf env;

static void handle_term(int ignored) {
  siglongjmp(env, 1);
}

void loop(struct settings_header * hdr, time_t * last_run) {
  typedef settings(hdr->path_size, hdr->prog_size, hdr->state_file_size) settings_t;
  settings_t * set = (settings_t *) hdr;

  sigset_t full_set;
  sigfillset(&full_set);
  volatile pid_t child = 0;

  if (sigsetjmp(env, 0) == 1) {
    if (child > 0)
      kill(child, SIGTERM);
    exit(EXIT_SUCCESS);
  }

  char * old_tz = getenv("TZ");
  if (old_tz)
    old_tz = strdup(old_tz);
  setenv("TZ", "", 1);
  tzset();

  struct sigaction act;
  memset(&act, 0, sizeof act);
  act.sa_handler = handle_term;
  if (sigaction(SIGTERM, &act, NULL) == -1)
    err(1, "setting SIGTERM handler");

  while (1) {
    time_t now = time(NULL);
    struct tm * now_tm = gmtime(&now);

    struct tm prev_tm;
    memmove(&prev_tm, now_tm, sizeof prev_tm);
    prev_tm.tm_hour = hdr->hour;
    prev_tm.tm_min = hdr->min;
    prev_tm.tm_sec = 0;
    if (now_tm->tm_hour < hdr->hour ||
        (now_tm->tm_hour == hdr->hour && now_tm->tm_min < hdr->min))
      --prev_tm.tm_mday;
    time_t prev = mktime(&prev_tm);

    if (!*last_run) {
      sigset_t old;
      sigprocmask(SIG_SETMASK, &full_set, &old);
      *last_run = prev;
      msync(last_run, sizeof *last_run, MS_SYNC);
      sigprocmask(SIG_SETMASK, &old, NULL);
    }

    struct tm next_tm;
    memmove(&next_tm, now_tm, sizeof next_tm);
    next_tm.tm_hour = hdr->hour;
    next_tm.tm_min = hdr->min;
    next_tm.tm_sec = 0;
    if (now_tm->tm_hour > hdr->hour ||
        (now_tm->tm_hour == hdr->hour && now_tm->tm_min >= hdr->min))
      ++next_tm.tm_mday;
    time_t next = mktime(&next_tm);

    if (prev > *last_run || *last_run > now) {
      child = fork();
      switch (child) {
        case -1:
          err(1, "forking to run %s", set->prog);
        case 0:
          if (old_tz)
            setenv("TZ", old_tz, 1);
          else
            unsetenv("TZ");
          tzset();
          execl(set->path, set->prog, NULL);
          err(212, "executing %s", set->prog);
      }
      int status;
      errno = EINTR;
      while (wait(&status) == -1 && errno == EINTR);
      if (errno != EINTR)
        err(1, "waiting for children");

      child = 0;

      sigset_t old;
      sigprocmask(SIG_SETMASK, &full_set, &old);
      time(last_run);
      msync(last_run, sizeof *last_run, MS_SYNC);
      sigprocmask(SIG_SETMASK, &old, NULL);

      if (*last_run < next)
        sleep(next - *last_run);
    } else
      sleep(next - now);
  }
}

#endif /* DEFNIX_TYPES_ONLY */
