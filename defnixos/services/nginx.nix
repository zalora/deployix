lib: lib.composable [ "build-support" [ "defnixos" "activations" ] "pkgs" [ "defnixos" "initializers" ] ] (

build-support@{ write-file }:

activations@{ socket }:

pkgs@{ multiplex-activations, execve, nginx }:

initializers@{ dirs }:

let

  config = port: extra-config: write-file "nginx-${toString port}.conf" ''
    user root root;

    daemon off;

    events {
      use epoll;
    }

    http {
      server {
        listen [::]:${toString port} ipv6only=off;
        ${extra-config}
      }
    }
  '';

in

# nginx web server

{ port # Port to listen on
, server-config # Contents of server block (don't include port configuration)
}:

{
  start = multiplex-activations (execve "start-nginx-${toString port}" {
    filename = "${nginx}/bin/nginx";

    # !!! TODO: Unshare state dir
    argv = [ "nginx" "-c" (config port server-config) "-p" "/tmp/nginx" ];

    envp = {
      NGINX = "3;";
    };
  }) [ (socket {
    family = lib.socket-address-families.AF_INET6;

    inherit port;
  }) ];

  on-demand = true;

  initializer = dirs { dir = "/tmp/nginx/logs"; };
})
