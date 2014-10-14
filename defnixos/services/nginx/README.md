nginx
======

A service to run the `nginx` web server. The service is started on-demand
when a request is made at the listening port.

Arguments
----------

* `port`: The port to listen on (default `80`)
* `config`: The `nginx` config file. It should only specify servers
  listening on `[::]:${port}` with `ipv6only=off`
* `prefix`: The prefix where temporary files etc. are written (default
  `/var/lib/nginx`)
* `log-dir`: The default directory for log files (default `/var/log/nginx`).
