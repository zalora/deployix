lib: lib.composable [ [ "defnixos" "activations" ] "pkgs" ] (

activations@{ socket }:

pkgs@{ multiplex-activations, execve, php }:

let

  ini = "${php}/etc/php-recommended.ini";

  /* TODO: Figure out logging */
  config = pool-name: builtins.toFile "php-fpm.conf" ''
    [global]
    daemonize = no
    error_log = syslog

    [${pool-name}]
    listen = /run/phpfpm/${pool-name}.sock
    slowlog = syslog
    user = root
    group = root
    pm = static
    pm.max_children = 10
  '';

in

# A php-fpm pool

{ pool-name # The name of the fpm pool
}:

{
  start = multiplex-activations (execve "start-php-fpm" {
    filename = "${php}/sbin/php-fpm";

    argv = [ "php-fpm" "-R" "--fpm-config" (config pool-name) "-c" ini ];

    envp = {
      FPM_SOCKETS = "/run/phpfpm/${pool-name}.sock=3";
    };
  }) [ (socket {
    family = lib.socket-address-families.AF_UNIX;

    path = "/run/phpfpm/${pool-name}.sock";
  }) ];

  on-demand = true;
})
