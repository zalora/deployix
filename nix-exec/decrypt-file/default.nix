defnix: let
  inherit (defnix.nix-exec) compile-plugin;

  inherit (defnix.native.pkgs) gpgme libgpgerror;
in compile-plugin [
  "-I${gpgme}/include"
  "-I${libgpgerror}/include"
  "${gpgme}/lib/libgpgme.so"
  ]
  ./decrypt-file.so.cc "decrypt" 3
