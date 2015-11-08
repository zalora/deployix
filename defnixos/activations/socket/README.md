socket
=======

An on-demand activation for listening on a socket. The activation is ready
when a connection arrives.

Arguments
----------

* `family`: The address family (should be a member of
  `deployix.lib.socket-address-families`)
* `path`: If `family` is `AF_UNIX`, the path to the socket to bind to.
* `port`: If `family` is `AF_INET6`, the port to listen on.

Execution environment changes
------------------------------

Opens the relevant socket on the next file descriptor.

Example
-------

See `<deployix/defnixos/services/php-fpm/default.nix>` for an example.
