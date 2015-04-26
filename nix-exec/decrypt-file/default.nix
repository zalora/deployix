defnix: let
  inherit (defnix.nix-exec) compile-plugin;
  inherit (defnix.native.pkgs) gnupg;

in compile-plugin [
  ''-DGPG2_PATH="${gnupg}/bin/gpg2"''
  ]
  ./decrypt-file.so.cc "decrypt" 3
