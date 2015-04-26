#include <spawn.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <cerrno>
#include <cstring>
#include <iostream>
#include <sstream>
#include <string>

#include <eval-inline.hh>
#include <eval.hh>
#include <store-api.hh>
#include <util.hh>

#ifndef GPG2_PATH
# define GPG2_PATH "gpg2"
#endif

static std::string
__decrypt (const std::string &path)
{
  const char gpg2_path [] = GPG2_PATH;
  const char * const argv[] = { gpg2_path
                              , "--batch"
                              , "--use-agent"
                              , "-d"
                              , path.c_str()
                              , nullptr
                              };
  int in[2];
  int status;
  short int flags = 0;
  pid_t child;
  posix_spawn_file_actions_t action;
  posix_spawnattr_t attr;

  pipe(in);
  posix_spawn_file_actions_init(&action);
  posix_spawnattr_init(&attr);
  posix_spawn_file_actions_adddup2(&action, in[1], 1);
  posix_spawn_file_actions_addclose(&action, in[0]);

#if defined(POSIX_SPAWN_USEVFORK)
  flags |= POSIX_SPAWN_USEVFORK;
#endif
  posix_spawnattr_setflags(&attr, flags);

  status = posix_spawnp(&child, gpg2_path, &action, &attr,
      const_cast<char * const *>(argv), environ);

  close(in[1]);
  posix_spawn_file_actions_destroy(&action);
  posix_spawnattr_destroy(&attr);

  errno = status;
  if (status)
    throw nix::SysError("posix_spawnp");

  std::string ret = nix::drainFD(in[0]);

  errno = 0;
  while (waitpid(child, &status, 0) == -1 && errno == EINTR)
    ;
  if (errno && errno != EINTR)
    throw nix::SysError("waiting for gpg2");

  if (WIFEXITED(status)) {
    auto code = WEXITSTATUS(status);
    if (code) {
      std::ostringstream msg;
      msg << "gpg2 exited with non-zero exit code " << code;
      throw nix::Error(msg.str());
    }
  } else if (WIFSIGNALED(status)) {
    std::ostringstream msg;
    msg << "gpg2 killed by signal " << strsignal(WTERMSIG(status));
    throw nix::Error(msg.str());
  } else {
    throw nix::Error("gpg2 died in unknown manner");
  }

  return ret;
}



extern "C" void decrypt( nix::EvalState & state
                       , const nix::Pos & pos
                       , nix::Value ** args
                       , nix::Value & v
                       ) {
  state.forceValue(*args[0]);

  auto name = state.forceStringNoCtx(*args[1], pos);

  auto ctx = nix::PathSet{};
  auto path = state.coerceToPath(pos, *args[2], ctx);
  nix::realiseContext(ctx);

  std::cerr << "decrypting `" << path << "' ..." << std::endl;
  auto contents = __decrypt (path);
  auto res = nix::store->addTextToStore (name, contents, nix::PathSet{});

  nix::mkString(v, res, nix::PathSet{res});
}

