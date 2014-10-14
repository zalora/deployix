services
=========

Functions that define defnixos services.

Format
-------

A service is an attribute set with the following attributes:

* `start`: The executable to run to start this service
* `on-demand`: A boolean switch specifying if this service is on-demand.
  on-demand services must support readiness notifications (see below)
  (default `false`)
* `initializer`: An executable that is guaranteed to run to completion at
  least once before the service is started for the first time, but may run
  multiple times and so should be idempotent. Can be absent.

It is expected that service manager implementations will use the semantic
information provided by `on-demand` and `initializer` to sensibly order
service startup.

Readiness notifications
-----------------------

In order to leverage on-demand startup to obviate the need for explicit
specification of inter-service dependencies, a somewhat complex ordering
of events need to be ensured. Essentially, we need *all* on-demand services
to be "listening" before *any* service, on-demand or not, is allowed to start.

To achieve this, on-demand services must, if the `NOTIFY_SOCKET` env var
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

[1]: http://www.freedesktop.org/software/systemd/man/sd_notify.html
