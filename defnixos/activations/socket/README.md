socket
=======

An on-demand activation for listening on a socket.

Arguments
----------

* `family`: The address family (should be a member of
  `defnix.lib.socket-address-families`)
* `path`: If `family` is `AF_UNIX`, the path to the socket to bind to.
* `port`: If `family` is `AF_INET6`, the port to listen on.

Execution environment changes
------------------------------

Opens the relevant socket on the next file descriptor.

Example
-------

See `<defnix/defnixos/services/php-fpm/default.nix>` for an example.
