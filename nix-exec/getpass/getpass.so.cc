#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
extern "C" {
#include <unistd.h>
}

#include <eval.hh>

extern "C" void nix_getpass( nix::EvalState & state
                           , const nix::Pos & pos
                           , nix::Value ** args
                           , nix::Value & v
                           ) {
  auto pass = getpass(state.forceStringNoCtx(*args[0]).c_str());

  if (!pass)
    throw nix::SysError("reading password");

  nix::mkString(v, pass);
}
