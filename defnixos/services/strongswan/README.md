strongswan
===========

A service to allow incoming ipsec connections from any host with a cert
signed by the right CA and on-demand outgoing ipsec connections to the
hosts in outgoing-hosts.

Arguments
----------

* `outgoing-hosts`: A list of hosts to make on-demand connections to (default
  `[]`)
* `ca`: The root CA certificate that is used to authenticate incoming connections
* `service-name`: The name of the service in the global service namespace
  (default `strongswan`)

Initialization
---------------

The service is initialized by `defnix.pkgs.generate-certs` and thus requires
a CSR to be signed before the initial service startup. See
`<defnix/pkgs/generate-certs/README.md>` for more details.
