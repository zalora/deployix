#include <sys/socket.h>
#include <sys/un.h>
#include <err.h>
#include <string.h>

int main(int argc, char ** argv) {
  int socket_fd = socket(PF_UNIX, SOCK_DGRAM, 0);
  if (socket_fd == -1)
    err(1, "Creating socket");

  struct sockaddr_un addr;
  memset(&addr, 0, sizeof addr);
  addr.sun_family = AF_UNIX;
  memmove(addr.sun_path, "notify.sock", sizeof "notify.sock");

  char c = '\0';
  ssize_t res =
    sendto(socket_fd, &c, sizeof c, 0, (struct sockaddr *) &addr, sizeof addr);
  if (res == -1)
    err(1, "Sending to notify.sock");

  return 0;
}
