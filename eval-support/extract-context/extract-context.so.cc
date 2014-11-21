#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <util.hh>
#include <eval.hh>

#if HAVE_BOEHMGC
#include <gc/gc_cpp.h>
#define NEW new (UseGC)
#else
#define NEW new
#endif

static void extract_context( nix::EvalState & state
                           , const nix::Pos & pos
                           , nix::Value ** args
                           , nix::Value & v
                           ) {
  using std::string;
  using nix::PathSet;
  auto string_sym = state.symbols.create("string");
  auto context_sym = state.symbols.create("context");
  auto subtype_sym = state.symbols.create("subtype");
  auto path_sym = state.symbols.create("path");
  auto output_sym = state.symbols.create("output");

  PathSet ctx;
  auto str = state.coerceToString(pos, *args[0], ctx, false, false);

  state.mkAttrs(v, 2);

  auto & vStr = *state.allocAttr(v, string_sym);
  nix::mkString(vStr, str);

  auto & vList = *state.allocAttr(v, context_sym);
  state.mkList(vList, ctx.size());
  size_t idx = 0;
  for (const auto & i : ctx) {
    vList.list.elems[idx] = state.allocValue();
    auto & vElem = *vList.list.elems[idx];
    nix::Value * vAttr;
    switch (i.at(0)) {
      case '/':
        state.mkAttrs(vElem, 3);
        vAttr = state.allocAttr(vElem, subtype_sym);
        nix::mkStringNoCopy(*vAttr, "source");
        vAttr = state.allocAttr(vElem, path_sym);
        nix::mkString(*vAttr, i, nix::singleton<PathSet>(i));
        break;
      case '=': {
        state.mkAttrs(vElem, 3);
        vAttr = state.allocAttr(vElem, subtype_sym);
        nix::mkStringNoCopy(*vAttr, "drv");
        vAttr = state.allocAttr(vElem, path_sym);
        auto substr = string(i, 1);
        nix::mkString(*vAttr, substr, nix::singleton<PathSet>("~" + substr));
        break;
      }
      case '~': {
        state.mkAttrs(vElem, 3);
        vAttr = state.allocAttr(vElem, subtype_sym);
        nix::mkStringNoCopy(*vAttr, "drv-as-source");
        vAttr = state.allocAttr(vElem, path_sym);
        auto substr = string(i, 1);
        nix::mkString(*vAttr, substr, nix::singleton<PathSet>("~" + substr));
        break;
      }
      case '!': {
        state.mkAttrs(vElem, 4);
        vAttr = state.allocAttr(vElem, subtype_sym);
        nix::mkStringNoCopy(*vAttr, "output");
        auto index = i.find("!", 1);
        vAttr = state.allocAttr(vElem, path_sym);
        auto substr = string(i, index + 1);
        nix::mkString(*vAttr, substr, nix::singleton<PathSet>("~" + substr));
        vAttr = state.allocAttr(vElem, output_sym);
        nix::mkString(*vAttr, string(i, 1, index -1));
        break;
      }
      default:
        state.mkAttrs(vElem, 3);
        vAttr = state.allocAttr(vElem, subtype_sym);
        nix::mkStringNoCopy(*vAttr, "unknown");
        vAttr = state.allocAttr(vElem, path_sym);
        nix::mkString(*vAttr, i);
    }
    vAttr = state.allocAttr(vElem, state.sType);
    nix::mkStringNoCopy(*vAttr, "context");
    vElem.attrs->sort();
    ++idx;
  }
  v.attrs->sort();
}

extern "C" void setup_extract_context( nix::EvalState & state
                                     , const nix::Pos & pos
                                     , nix::Value ** args
                                     , nix::Value & v
                                     ) {
  v.type = nix::tPrimOp;
  v.primOp = NEW nix::PrimOp( extract_context
                            , 1
                            , state.symbols.create("extract-context")
                            );
}
