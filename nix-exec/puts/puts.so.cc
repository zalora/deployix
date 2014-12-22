#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <iostream>

#include <eval.hh>

extern "C" void nix_puts( nix::EvalState & state
                        , const nix::Pos & pos
                        , nix::Value ** args
                        , nix::Value & v
                        ) {
  auto ctx = nix::PathSet{};
  auto msg = state.coerceToString(pos, *args[0], ctx, false, false);
  nix::realiseContext(ctx);
  std::cout << msg;
  nix::mkNull(v);
}
