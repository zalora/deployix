lib: lib.composable [ [ "defnixos" "activations" ] "pkgs" ] (

activations@{ socket }:

pkgs@{ multiplex-activations, execve, php }:

# A php-fpm pool

{ socket-path # The path to the fpm socket
, config # the php-fpm config
, ini ? "${php}/etc/php-recommended.ini" # php.ini
, user ? "nginx" # user to run as (php-fpm most often used with nginx)
}:

{
  start = multiplex-activations (execve "start-php-fpm" {
    filename = "${php}/sbin/php-fpm";

    argv = [ "php-fpm" "--fpm-config" config "-c" ini ];

    envp = {
      FPM_SOCKETS = "${socket-path}=3";
    };

    inherit user;
  }) [ (socket {
    family = lib.socket-address-families.AF_UNIX;

    path = socket-path;
  }) ];

  on-demand = true;
})
