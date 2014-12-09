sshd
======

A service to run the `sshd` daemon. The service is started on-demand
when a request is made at the listening port.

Arguments
----------

* `passwd`: The file to use as `/etc/passwd`
* `group`: The file to use as `/etc/group`
* `port`: The port to listen on
* `config`: The configuration file
