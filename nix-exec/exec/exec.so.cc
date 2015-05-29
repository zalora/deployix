#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <memory>
extern "C" {
#include <unistd.h>
}

#include <eval.hh>
#include <eval-inline.hh>

extern "C" void nix_exec( nix::EvalState & state
                        , const nix::Pos & pos
                        , nix::Value ** args
                        , nix::Value & v
                        ) {
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
    argv_ptr[i + 1] = argv_list.back().c_str();
  }
  auto argv = argv_ptr.get();

  nix::realiseContext(ctx);

  /* const cast is fine, execvp doesn't modify its arg just has bad interface */
  execvp(file, const_cast<char **>(argv));
  throw nix::SysError(boost::format("executing `%1%'") % filename_str);
}
