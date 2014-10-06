#include <stdalign.h>
#include <sys/inotify.h>
#include <err.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <libgen.h>
#include <sys/ioctl.h>

int main(int argc, char ** argv) {
  if (argc != 2)
    errx(1, "Usage: %s FILE", argv[0]);

  int inotify_fd = inotify_init();
  if (inotify_fd == -1)
    err(1, "Initializing inotify");

  char *path = argv[1];
  char path_sz = strlen(path) + 1;

  char dirname_arg[path_sz];
  memcpy(dirname_arg, path, path_sz);
  char * dir = dirname(dirname_arg);

  char basename_arg[path_sz];
  memcpy(basename_arg, path, path_sz);
  char * file = basename(basename_arg);

  int watch = inotify_add_watch(inotify_fd, dir, IN_CREATE | IN_ONLYDIR);
  if (watch == -1)
    err(1, "Watching %s", dir);

  if (access(path, F_OK) == 0)
    return 0;

  size_t bufsz = sizeof(struct inotify_event) + strlen(file) + 1;
  while (1) {
    alignas(struct inotify_event) char buffer[bufsz];
    struct inotify_event * ev = (struct inotify_event *) buffer;

    ssize_t count = read(inotify_fd, buffer, bufsz);
    if (count == -1) {
      switch (errno) {
        case EINVAL:
          {
            int newsz;
            if (ioctl(inotify_fd, FIONREAD, &newsz) == -1)
              err(1, "Determining inotify read buffer size");
            bufsz = newsz;
          }
        case EINTR:
          continue;
        default:
          err(1, "Reading inotify events");
      }
    }

    while (count) {
      if (ev->mask & IN_CREATE && strcmp(ev->name, file) == 0)
        return 0;

      if (ev->mask & IN_Q_OVERFLOW && access(path, F_OK) == 0)
        return 0;

      if (ev->mask & IN_IGNORED)
        errx(2, "%s was deleted or unmounted", dir);

      size_t consumed = sizeof &ev + ev->len;

      count -= consumed;

      ev = (struct inotify_event *) ((char *) ev) + consumed;
    }
  }
}
