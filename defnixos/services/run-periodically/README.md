run-periodically
=================

A service to run a program at specified intervals. See
`<defnix/pkgs/run-periodically/README.md>` for more details.

Arguments
----------

* `service-name`: The name of the service in the global service namespace
* `state-dir`: A state directory for the service. Defautls to `/var/lib/${service-name}`
* `prog`, `hour`, `min`: See `<defnix/pkgs/run-periodically/README.md>`
