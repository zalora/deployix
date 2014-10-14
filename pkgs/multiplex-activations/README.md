multiplex-activations
======================

`multiplex-activations` multiplexes several activations together, starting
the requested program when any of them are ready.

Arguments
----------

* `activations`: A list of activations, called in order (see
  `<defnix/defnixos/activations/README.md>` for more details)
* `start`: The program to run when ready.

Readiness notifications
-----------------------

In order to leverage on-demand startup to obviate the need for explicit
specification of inter-service dependencies, a somewhat complex ordering
of events need to be ensured. Essentially, we need *all* on-demand services
to be "listening" before *any* service, on-demand or not, is allowed to start.

To achieve this, `multiplex-activations` will, if the `NOTIFY_SOCKET` env var
is set:

1. Send the datagram `READY=1` to the notify socket ([this][1] explains the
   `NOTIFY_SOCKET` protocol, which wile currently only implemented by `systemd`
   is not inherently `systemd` specific.
2. Wait for any datagram to be sent to `notify.sock` in the working directory
   of the service.

after all activations are listening but before allowing the service to actually
start. Step 1 tells the service manager that this on-demand service is
listening, while step 2 is the service manager telling this service that *all*
on-demand services are listening.

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

[1]: http://www.freedesktop.org/software/systemd/man/sd_notify.html
