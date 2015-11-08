ipsec
================

Transform a set of functionalities to include an ad-hoc peer-to-peer ipsec
network.

Arguments
----------

* `ca`: The SSL certificate to use as the CA for connections
* `cert-archive`: A pkcs12 archive containing keys and certs signed by
  `ipsec-ca`
* `functionalities`: The functionalities to deploy

Custom functionalities attributes
----------------------------------

* `outgoing-hosts`: A set of hosts to enable outgoing secure connections to

See `<deployix/defnixos/services/strongswan/README.md>` for more details.

Return
-------

A new `functionality` set that covers the behavior of the existing set, while
also enabling incoming ipsec connections from any server with a certificate
signed by `ca` and outgoing ipsec connections to any servers listed in
`outgoing-hosts`
