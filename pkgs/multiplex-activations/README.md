multiplex-activations
======================

`multiplex-activations` multiplexes several activations together, starting
the requested program when any of them are ready. `multiplex-activations`
supports readiness notifications (see `<defnix/defnixos/services/README.md>`)

Arguments
----------

* `activations`: A list of activations, called in order (see
  `<defnix/defnixos/activations/README.md>` for more details)
* `start`: The program to run when ready.

run-with-settings
------------------

`multiplex-activations` specializes `run-with-settings`
(see `<defnix/pkgs/run-with-settings/README.md>` for more details) such that
the underlying service, *not* the activations, is run with the given settings.
This is so that services can acquire resources like sockets as a privileged
user then run as an unprivileged one.

Example
--------

See `<defnix/defnixos/services/php-fpm/default.nix>` for an example.
