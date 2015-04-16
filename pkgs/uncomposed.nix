lib: (lib.recursive-import ./.) // {
  # Core POSIX utilities
  coreutils = defnix: defnix.nixpkgs.coreutils;

  # A POSIX shell
  sh = defnix: "${defnix.nixpkgs.bash}/bin/bash";

  # The strongswan IKEv2 daemon
  strongswan = defnix: defnix.nixpkgs.strongswan;

  # Linux kernel module tools
  kmod = defnix: defnix.nixpkgs.kmod;

  # Open source toolkit for SSL/TLS
  openssl = defnix: defnix.nixpkgs.openssl;

  # The PHP hypertext processor
  php = defnix: defnix.nixpkgs.php;

  # The nginx web server
  nginx = defnix: defnix.nixpkgs.nginx;

  # The nix package manager
  nix = defnix: defnix.nixpkgs.nix;

  # The boehm garbage collector
  boehmgc = defnix: defnix.nixpkgs.boehmgc;

  # The GNU privacy guard
  gnupg = defnix: defnix.nixpkgs.gnupg;

  # GnuPG Made Easy, a library to access to GnuPG
  gpgme = defnix: defnix.nixpkgs.gpgme;

  # library that defines common error values for all GnuPG components
  libgpgerror = defnix: defnix.nixpkgs.libgpgerror;

  # The openssh SSH suite
  openssh = defnix: defnix.nixpkgs.openssh;

  # GNU Diff
  diffutils = defnix: defnix.nixpkgs.diffutils;

  # systemd init system
  systemd = defnix: defnix.nixpkgs.systemd;

  # GNU grep
  gnugrep = defnix: defnix.nixpkgs.gnugrep;

  # The newrelic system monitoring daemon
  newrelic-sysmond = defnix: defnix.nixpkgs.newrelic-sysmond;

  # Interactive version of bash
  bash-interactive = defnix: "${defnix.nixpkgs.bashInteractive}/bin/bash";

  # Misc linux utilities
  utillinux = defnix: defnix.nixpkgs.utillinux;
}
