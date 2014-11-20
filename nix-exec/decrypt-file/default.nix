defnix: let
  inherit (defnix.nix-exec) compile-plugin;

  inherit (defnix.native.pkgs) gnupg;
in compile-plugin [ "-Wno-write-strings" ''-DGPG="${gnupg}/bin/gpg2"'' ]
  ./decrypt-file.so.cc "decrypt" 3
