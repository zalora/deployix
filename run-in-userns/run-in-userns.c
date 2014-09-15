#define _GNU_SOURCE
#include <unistd.h>
#include <linux/sched.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int main(int argc, char ** argv) {
  uid_t uid = getuid();
  gid_t gid = getgid();

  if (unshare(CLONE_NEWUSER) == -1) {
    perror("Entering user namespace");
    return 1;
  }

  int uid_map_fd = open("/proc/self/uid_map", O_WRONLY | O_CLOEXEC);
  if (uid_map_fd == -1) {
    perror("Opening /proc/self/uid_map");
    return 1;
  }

  int sz = snprintf(NULL, 0, "0 %d 1", uid);
  char uid_map_buf[sz + 1];
  snprintf(uid_map_buf, sz + 1, "0 %d 1", uid);
  if (write(uid_map_fd, uid_map_buf, sz) == -1) {
    perror("Writing to /proc/self/uid_map");
    return 1;
  }

  int gid_map_fd = open("/proc/self/gid_map", O_WRONLY | O_CLOEXEC);
  if (gid_map_fd == -1) {
    perror("Opening /proc/self/gid_map");
    return 1;
  }

  sz = snprintf(NULL, 0, "0 %d 1", gid);
  char gid_map_buf[sz + 1];
  snprintf(gid_map_buf, sz + 1, "0 %d 1", gid);
  if (write(gid_map_fd, gid_map_buf, sz) == -1) {
    perror("Writing to /proc/self/gid_map");
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
