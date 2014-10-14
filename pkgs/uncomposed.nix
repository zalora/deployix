lib: (lib.recursive-import ./.) // {
  # Core POSIX utilities
  coreutils = defnix: defnix.nixpkgs.coreutils;

  # A POSIX shell
  sh = defnix: "${defnix.pkgs.bash}/bin/bash";

  # The strongswan IKEv2 daemon
  strongswan = defnix: defnix.pkgs.strongswan;

  # Linux kernel module tools
  kmod = defnix: defnix.pkgs.kmod;

  # Open source toolkit for SSL/TLS
  openssl = defnix: defnix.nixpkgs.openssl;

  # The PHP hypertext processor
  php = defnix: defnix.nixpkgs.php;

  # The nginx web server
  nginx = defnix: defnix.nixpkgs.nginx;
}
