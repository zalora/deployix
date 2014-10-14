php-fpm
=======

A service to run the `php-fpm` FastCGI process manager. The service is started
on-demand when a connection is made to the listening socket.

Arguments
----------

* `socket-path`: The path to the listening socket
* `config`: The `php-fpm` config file
* `ini`: The `php.ini` file to use, defaults to `php`'s `php-recommended.ini`.
