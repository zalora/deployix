#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <string>
#include <iostream>
#include <utility>
extern "C" {
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h>
}

#include <eval.hh>
#include <eval-inline.hh>
#include <util.hh>
#include <store-api.hh>

class filedes {
  int fd;

  void close() noexcept {
    if (fd != -1 && ::close(fd) == -1)
      std::cerr << "error closing file descriptor: " << strerror(errno);
  };

  public:
  filedes() : fd{-1} {};

  filedes(int fd) : fd{fd} {};

  filedes(const filedes &) = delete;

  filedes(filedes && that) : fd{that.fd} {
    that.fd = -1;
  };

  filedes & operator=(const filedes &) & = delete;

  filedes & operator=(filedes && that) & {
    close();
    fd = that.fd;
    that.fd = -1;
    return *this;
  };

  ~filedes() {
    close();
  };

  explicit operator int() {
    return fd;
  };

  explicit operator bool() {
    return fd != -1;
  };

  void set_cloexec() {
    ::fcntl(fd, F_SETFD, fcntl(fd, F_GETFD) | FD_CLOEXEC);
  };
};

extern "C" void decrypt( nix::EvalState & state
                       , const nix::Pos & pos
                       , nix::Value ** args
                       , nix::Value & v
                       ) {
  state.forceValue(*args[0]);

  auto needsPass = true;
  auto passString = std::string{};
  if (args[0]->type == nix::tNull)
    needsPass = false;
  else
    passString = state.forceStringNoCtx(*args[0], pos);

  auto name = state.forceStringNoCtx(*args[1], pos);

  auto ctx = nix::PathSet{};
  auto path = state.coerceToPath(pos, *args[2], ctx);
  nix::realiseContext(ctx);

  int pipe_fds[2];
  filedes fds[4];

  if (pipe(pipe_fds) == -1)
    throw nix::SysError("creating pipes");

  fds[0] = filedes{pipe_fds[0]};
  fds[1] = filedes{pipe_fds[1]};

  if (needsPass) {
    if (pipe(pipe_fds) == -1)
      throw nix::SysError("creating pipes");

    fds[2] = filedes{pipe_fds[0]};
    fds[3] = filedes{pipe_fds[1]};
  }

  fds[0].set_cloexec();
  fds[1].set_cloexec();
  if (needsPass)
    fds[3].set_cloexec();

  auto fourth_arg = needsPass ? std::to_string(static_cast<int>(fds[2])) : "-d";

  const char * argv[] = { "gpg2"
                        , "--batch"
                        , needsPass ? "--passphrase-fd" : "--use-agent"
                        , fourth_arg.c_str()
                        , needsPass ? "-d" : path.c_str()
                        , needsPass ? path.c_str() : NULL
                        , NULL
                        };
  switch (fork()) {
    case -1:
      throw nix::SysError("forking to run gpg2");
    case 0:
      if (dup2(static_cast<int>(fds[1]), STDOUT_FILENO) == -1) {
        perror("duping pipe to stdout");
        _exit(213);
      }
      /* const-correct because execv swears not to modify argv */
      execv(GPG, const_cast<char **>(argv));
      perror("executing gpg");
      _exit(212);
  }

  if (needsPass) {
    nix::writeFull( static_cast<int>(fds[3])
                  , reinterpret_cast<const unsigned char *>(passString.c_str())
                  , passString.size()
                  );

    fds[3] = filedes{};
  }

  fds[1] = filedes{};

  /* nix has no way to stream a file to the store, so just stuff everything
   * into a string */
  auto contents = nix::drainFD(static_cast<int>(fds[0]));

  int status;
  while(wait(&status) == -1);
  if (WIFEXITED(status)) {
    if (WEXITSTATUS(status))
      throw nix::EvalError(boost::format("gpg2 exited with non-zero exit code %1%")
          % WEXITSTATUS(status));
  } else
    throw nix::EvalError(boost::format("gpg2 killed by signal %1%")
        % WTERMSIG(status));

  auto res = nix::store->addTextToStore( name
                                       , contents
                                       , nix::PathSet{}
                                       );

  nix::mkString(v, res, nix::PathSet{res});
}
