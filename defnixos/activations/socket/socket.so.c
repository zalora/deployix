#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <err.h>
#include <stdarg.h>
#include <libgen.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/epoll.h>

static void mkdir_p(char * dir) {
  for (char * sep = strchr(dir + 1, '/'); sep; sep = strchr(sep + 1, '/')) {
    *sep = '\0';
    if (mkdir(dir, 0755) == -1 && errno != EEXIST)
      err(1, "Creating directory %s", dir);
    *sep = '/';
  }
  if (mkdir(dir, 0755) == -1 && errno != EEXIST)
    err(1, "Creating directory %s", dir);
}

void activate(int epoll_fd, void * args) {
  size_t * path_len = (size_t *) args;
  args += sizeof(size_t);
  char * path = (char *) args;

  struct sockaddr_un addr;
  if (*path_len > sizeof addr - offsetof(struct sockaddr_un, sun_path))
    errx(1, "Path %s too long for a unix socket", path);

  char path_copy[*path_len];
  memmove(path_copy, path, *path_len);
  mkdir_p(dirname(path_copy));

  int sock_fd = socket(PF_UNIX, SOCK_STREAM, 0);
  if (sock_fd == -1)
    err(1, "Opening socket for activation");

  if (unlink(path) == -1 && errno != ENOENT)
    err(1, "Unlinking %s", path);

  memset(&addr, 0, sizeof addr);
  addr.sun_family = AF_UNIX;
  memmove(addr.sun_path, path, *path_len);
  if (bind(sock_fd, (struct sockaddr *) &addr, sizeof addr) == -1)
    err(1, "Binding socket");

  struct epoll_event ev;
  memset(&ev, 0, sizeof ev);
  ev.events = EPOLLIN | EPOLLET | EPOLLONESHOT;
  if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, sock_fd, &ev) == -1)
    err(1, "Registering socket with epoll fd");

  if (chmod(path, 0666) == -1)
    err(1, "Changing ownership of socket");

  if (listen(sock_fd, SOMAXCONN) == -1)
    err(1, "Listening on socket");
}
