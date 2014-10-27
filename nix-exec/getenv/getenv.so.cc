#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
extern "C" {
#include <stdlib.h>
}

#include <eval.hh>

extern "C" void nix_getenv( nix::EvalState & state
                          , const nix::Pos & pos
                          , nix::Value ** args
                          , nix::Value & v
                          ) {
  auto env = getenv(state.forceStringNoCtx(*args[0]).c_str());

  if (!env)
    nix::mkNull(v);
  else
    nix::mkString(v, env);
}
