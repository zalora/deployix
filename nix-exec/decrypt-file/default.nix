deployix: let
  inherit (deployix.nix-exec) compile-plugin;
  inherit (deployix.native.pkgs) gnupg;

in compile-plugin [
  ''-DGPG2_PATH="${gnupg}/bin/gpg2"''
  ]
  ./decrypt-file.so.cc "decrypt" 3
