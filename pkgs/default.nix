lib: lib.composable-set ((lib.import-subdirs ./. [
  "wait-for-file"
]) // {
  coreutils = lib.composable [ "nixpkgs" ] (nixpkgs@{ coreutils }: coreutils);

  sh = lib.composable [ "nixpkgs" ] (nixpkgs@{ sh }: sh);

  strongswan = lib.composable [ "nixpkgs" ] (nixpkgs@{ strongswan }: strongswan);

  kmod = lib.composable [ "nixpkgs" ] (nixpkgs@{ kmod }: kmod);

  openssl = lib.composable [ "nixpkgs" ] (nixpkgs@{ openssl }: openssl);
})
