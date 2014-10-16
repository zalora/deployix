#ifndef DEFNIX_TYPES_ONLY
#define _GNU_SOURCE
#endif

#include ACTIVATION_HEADER
#include <stdint.h>

enum socket_addr_type {
  socket_addr_un,
  socket_addr_ipv6
};

#define socket_addr_header(f_sz, s_sz) \
  struct { \
    activation_header(f_sz, s_sz) act_hdr; \
    enum socket_addr_type type; \
  }

#define ipv6_addr(f_sz, s_sz) \
  struct { \
    socket_addr_header(f_sz, s_sz) addr_hdr; \
    uint16_t port; \
  }

#define un_addr_header(f_sz, s_sz) \
  struct { \
    socket_addr_header(f_sz, s_sz) addr_hdr; \
    size_t path_size; \
  }

#define un_addr(f_sz, s_sz, u_sz) \
  struct { \
    un_addr_header(f_sz, s_sz) un_hdr; \
    char path[(u_sz)]; \
  }

#ifndef DEFNIX_TYPES_ONLY
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
#include <netinet/in.h>

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

static int bind_un(struct activation_header_sizes * sizes) {
  typedef un_addr_header(sizes->filename_size, sizes->symbol_size) u_hdr;
  u_hdr * settings_hdr = (u_hdr *) sizes;
  typedef un_addr( sizes->filename_size
                 , sizes->symbol_size
                 , settings_hdr->path_size
                 ) u_addr;
  u_addr * settings = (u_addr *) sizes;

  struct sockaddr_un addr;
  if (settings_hdr->path_size > sizeof addr - offsetof(struct sockaddr_un, sun_path))
    errx(1, "Path %s too long for a unix socket", settings->path);

  char path_copy[settings_hdr->path_size];
  memmove(path_copy, settings->path, settings_hdr->path_size);
  mkdir_p(dirname(path_copy));

  int sock_fd = socket(PF_UNIX, SOCK_STREAM, 0);
  if (sock_fd == -1)
    err(1, "Opening socket for activation");

  if (unlink(settings->path) == -1 && errno != ENOENT)
    err(1, "Unlinking %s", settings->path);

  memset(&addr, 0, sizeof addr);
  addr.sun_family = AF_UNIX;
  memmove(addr.sun_path, settings->path, settings_hdr->path_size);
  if (bind(sock_fd, (struct sockaddr *) &addr, sizeof addr) == -1)
    err(1, "Binding socket");

  if (chmod(settings->path, 0666) == -1)
    err(1, "Changing ownership of socket");

  return sock_fd;
}

static int bind_ipv6(struct activation_header_sizes * sizes) {
  typedef ipv6_addr(sizes->filename_size, sizes->symbol_size) i_addr;
  i_addr * settings = (i_addr *) sizes;

  int sock_fd = socket(PF_INET6, SOCK_STREAM, 0);
  if (sock_fd == -1)
    err(1, "Opening socket for activation");

  struct sockaddr_in6 addr;
  memset(&addr, 0, sizeof addr);
  addr.sin6_family = AF_INET6;
  addr.sin6_port = htons(settings->port);
  addr.sin6_addr = in6addr_any;

  int no = 0;
  if (setsockopt(sock_fd, IPPROTO_IPV6, IPV6_V6ONLY, &no, sizeof no) == -1)
    err(1, "Turning off ipv6only");

  int yes = 1;
  if (setsockopt(sock_fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof yes) == -1)
    err(1, "Turning on SO_REUSEADDR");

  if (bind(sock_fd, (struct sockaddr *) &addr, sizeof addr) == -1)
    err(1, "Binding to [::]:%d", settings->port);

  return sock_fd;
}

static int bind_sock(struct activation_header_sizes * sizes) {
  typedef socket_addr_header(sizes->filename_size, sizes->symbol_size) s_addr;
  s_addr * addr = (s_addr *) sizes;
  switch (addr->type) {
    case socket_addr_un:
      return bind_un(sizes);
    default: /* socket_addr_ipv6 */
      return bind_ipv6(sizes);
  }
}

void activate(int epoll_fd, struct activation_header_sizes * sizes) {
  int sock_fd = bind_sock(sizes);

  struct epoll_event ev;
  memset(&ev, 0, sizeof ev);
  ev.events = EPOLLIN | EPOLLET | EPOLLONESHOT;
  if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, sock_fd, &ev) == -1)
    err(1, "Registering socket with epoll fd");

  if (listen(sock_fd, SOMAXCONN) == -1)
    err(1, "Listening on socket");
}

#endif /* DEFNIX_TYPES_ONLY */
