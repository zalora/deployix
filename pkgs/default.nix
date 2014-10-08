lib: lib.composable-set ((lib.import-subdirs ./. [
  "wait-for-file"
  "execve"
  "multiplex-activations"
  "notify-readiness"
  "run-with-settings"
  "par"
  "seq"
  "generate-certs"
  "fake-sendmail"
]) // {
  coreutils = lib.composable [ "nixpkgs" ] (nixpkgs@{ coreutils }: coreutils);

  sh = lib.composable [ "nixpkgs" ] (nixpkgs@{ bash }: "${bash}/bin/bash");

  strongswan = lib.composable [ "nixpkgs" ] (nixpkgs@{ strongswan }: strongswan);

  kmod = lib.composable [ "nixpkgs" ] (nixpkgs@{ kmod }: kmod);

  openssl = lib.composable [ "nixpkgs" ] (nixpkgs@{ openssl }: openssl);

  php = lib.composable [ "nixpkgs" ] (nixpkgs@{ php }: php);

  nginx = lib.composable [ "nixpkgs" ] (nixpkgs@{ nginx }: nginx);
})
