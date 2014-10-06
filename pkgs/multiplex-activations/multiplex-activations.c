#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <sys/un.h>
#include <stddef.h>
#include <sys/socket.h>
#include <err.h>
#include <sys/epoll.h>
#include <sys/mman.h>
#include <dlfcn.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

static void notify() {
  const char * notify_addr = getenv("NOTIFY_SOCKET");
  if (!notify_addr)
    return;

  int notify_socket = socket(PF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
  if (notify_socket == -1)
    err(1, "Creating datagram socket");

  struct sockaddr_un local_addr;
  memset(&local_addr, 0, sizeof local_addr);
  local_addr.sun_family = AF_UNIX;
  memmove(local_addr.sun_path, "notify.sock", sizeof "notify.sock");

  if (unlink("notify.sock") == -1 && errno != ENOENT)
    err(1, "Unlinking notify.sock");

  if (bind(notify_socket, (struct sockaddr *) &local_addr, sizeof local_addr) == -1)
    err(1, "Binding to notify.sock");

  size_t notify_addr_len = strlen(notify_addr) + 1;
  struct sockaddr_un remote_addr;
  if (notify_addr_len > (sizeof remote_addr) - offsetof(struct sockaddr_un, sun_path))
    errx(1, "NOTIFY_SOCKET path length too long");

  memset(&remote_addr, 0, sizeof remote_addr);
  remote_addr.sun_family = AF_UNIX;
  memmove(remote_addr.sun_path, notify_addr, notify_addr_len);

  if (remote_addr.sun_path[0] == '@')
    remote_addr.sun_path[0] = '\0';

  const char ready[] = { 'R', 'E', 'A', 'D', 'Y', '=', '1' };
  ssize_t res =
    sendto(notify_socket, ready, sizeof ready, 0, (struct sockaddr *)&remote_addr, sizeof remote_addr);
  if (res == -1)
    err(1, "Sending ready notification");

  char c;
  res = read(notify_socket, &c, sizeof c);
  if (res == -1)
    err(1, "Reading from notify socket");
}

int main(int argc, char ** argv) {
  int epoll_fd = epoll_create1(EPOLL_CLOEXEC);
  if (epoll_fd == -1)
    err(1, "Opening epoll fd");

  int top_fd = sysconf(_SC_OPEN_MAX) - 1;
  if (dup3(epoll_fd, top_fd, O_CLOEXEC) == -1)
    err(1, "Duping epoll fd to a high descriptor");

  if (close(epoll_fd) == -1)
    err(1, "Closing original epoll fd");

  epoll_fd = top_fd;

  char * filename = *(++argv);
  char * progname = *(++argv);

  while (*(++argv)) {
    char * arg_file = *argv;
    int arg_file_fd = open(arg_file, O_RDONLY);
    if (arg_file_fd == -1)
      err(1, "Opening %s", arg_file);

    struct stat st;
    if (fstat(arg_file_fd, &st) == -1)
      err(1, "Statting %s fd", arg_file);

    void * map =
      mmap(NULL, st.st_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, arg_file_fd, 0);

    void * map_iter = map;

    if (map == MAP_FAILED)
      err(1, "Mapping %s into memory", arg_file);

    if (close(arg_file_fd) == -1)
      err(1, "Closing %s", arg_file);

    size_t * filename_size = (size_t *) map_iter;
    map_iter += sizeof(size_t);
    char * filename = (char *) map_iter;
    map_iter += *filename_size;

    size_t * symbol_size = (size_t *) map_iter;
    map_iter += sizeof(size_t);
    char * symbol = (char *) map_iter;
    map_iter += *symbol_size;

    void * handle = dlopen(filename, RTLD_LAZY | RTLD_LOCAL);
    if (!handle)
      errx(1, "Dynamically loading %s: %s", filename, dlerror());

    typedef void (*activation)(int epoll_fd, void * args);
    dlerror();
    activation act = (activation) dlsym(handle, symbol);
    if (!act) {
      char * err_str = dlerror();
      if (!err_str)
        errx(1, "Symbol %s from %s is NULL", symbol, filename);
      else
        errx(1, "Loading symbol %s from %s: %s", symbol, filename, err_str);
    }

    act(epoll_fd, map_iter);

    if (munmap(map, st.st_size) == -1)
      err(1, "Unmapping %s", arg_file);
  }

  notify();

  struct epoll_event ev;
wait:
  if (epoll_wait(epoll_fd, &ev, 1, -1) == -1) {
    if (errno == EINTR)
      goto wait;
    else
      err(1, "Waiting for an activation to be ready");
  }

  execl(filename, progname, NULL);
  err(1, "Executing %s", filename);
}
