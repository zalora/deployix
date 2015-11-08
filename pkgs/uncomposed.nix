lib: (lib.recursive-import ./.) // {
  # Core POSIX utilities
  coreutils = deployix: deployix.nixpkgs.coreutils;

  # A POSIX shell
  sh = deployix: "${deployix.nixpkgs.bash}/bin/bash";

  # The strongswan IKEv2 daemon
  strongswan = deployix: deployix.nixpkgs.strongswan;

  # Linux kernel module tools
  kmod = deployix: deployix.nixpkgs.kmod;

  # Open source toolkit for SSL/TLS
  openssl = deployix: deployix.nixpkgs.openssl;

  # The PHP hypertext processor
  php = deployix: deployix.nixpkgs.php;

  # The nginx web server
  nginx = deployix: deployix.nixpkgs.nginx;

  # The nix package manager
  nix = deployix: deployix.nixpkgs.nixUnstable;

  # The boehm garbage collector
  boehmgc = deployix: deployix.nixpkgs.boehmgc;

  # The GNU privacy guard
  gnupg = deployix: deployix.nixpkgs.gnupg;

  # The openssh SSH suite
  openssh = deployix: deployix.nixpkgs.openssh;

  # GNU Diff
  diffutils = deployix: deployix.nixpkgs.diffutils;

  # systemd init system
  systemd = deployix: deployix.nixpkgs.systemd;

  # GNU grep
  gnugrep = deployix: deployix.nixpkgs.gnugrep;

  # The newrelic system monitoring daemon
  newrelic-sysmond = deployix: deployix.nixpkgs.newrelic-sysmond;

  # Interactive version of bash
  bash-interactive = deployix: "${deployix.nixpkgs.bashInteractive}/bin/bash";

  # Misc linux utilities
  utillinux = deployix: deployix.nixpkgs.utillinux;
}
