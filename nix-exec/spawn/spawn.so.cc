#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <cerrno>
#include <memory>
extern "C" {
#include <unistd.h>
#include <sys/wait.h>
}

#include <eval.hh>
#include <eval-inline.hh>

extern "C" void nix_spawn( nix::EvalState & state
                         , const nix::Pos & pos
                         , nix::Value ** args
                         , nix::Value & v
                         ) {
  auto signalled_sym = state.symbols.create("signalled");
  auto code_sym = state.symbols.create("code");

  auto ctx = nix::PathSet{};
  auto filename_str = state.coerceToString(pos, *args[0], ctx, false, false);
  auto file = filename_str.c_str();

  state.forceList(*args[1], pos);
  auto argv_list = nix::Strings();
  auto argv_ptr =
    std::unique_ptr<const char*[]>{new const char*[args[1]->list.length + 2]};
  argv_ptr[0] = file;
  argv_ptr[args[1]->list.length + 1] = nullptr;
  for (size_t i = 0; i < args[1]->list.length; ++i) {
    argv_list.push_back(state.coerceToString( pos
                                            , *args[1]->list.elems[i]
                                            , ctx
                                            , true
                                            , false
                                            ));
    argv_ptr[i] = argv_list.back().c_str();
  }
  auto argv = argv_ptr.get();

  nix::realiseContext(ctx);

  auto child = vfork();
  switch (child) {
    case -1:
      throw nix::SysError("forking");
    case 0:
      execvp(file, const_cast<char **>(argv));
      _exit(212);
  }
  int status;
  errno = 0;
  while (waitpid(child, &status, 0) == -1 && errno == EINTR);
  if (errno && errno != EINTR)
    throw nix::SysError("Waiting for child");

  state.mkAttrs(v, 2);
  auto code_val = state.allocAttr(v, code_sym);
  auto signalled_val = state.allocAttr(v, signalled_sym);

  if (WIFEXITED(status)) {
    mkBool(*signalled_val, false);
    mkInt(*code_val, WEXITSTATUS(status));
  } else {
    mkBool(*signalled_val, true);
    mkInt(*code_val, WTERMSIG(status));
  }

  v.attrs->sort();
}
