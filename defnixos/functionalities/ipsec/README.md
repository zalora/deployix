ipsec
================

Transform a set of functionalities to include an ad-hoc peer-to-peer ipsec
network.

Arguments
----------

* `functionalities`: The functionalities to deploy

Custom functionalities attributes
----------------------------------

* `ipsec-ca`: The SSL certificate to use as the CA for connections
* `ipsec-cert-archive`: A pkcs12 archive containing keys and certs for the
  functionality
* `outgoing-hosts`: A set of hosts to enable outgoing secure connections to

See `<defnix/defnixos/services/strongswan/README.md>` for more details.

Return
-------

A new `functionality` set that covers the behavior of the existing set, while
also enabling incoming ipsec connections from any server with a certificate
signed by `ipsec-ca` and outgoing ipsec connections to any servers listed in
`outgoing-hosts`

Limitations
------------

Currently requires each functionality to match in `ipsec-ca` and
`ipsec-cert-archive`. Assumes all functionalities are deployed to a single
machine and will break if not.
