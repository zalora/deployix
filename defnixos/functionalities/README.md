Functionalities
==============================

Functions to handle functionalities.

Functionalities
----------------

The functionality interface provides an extensible way to specify the behavior
desired from the deployment. A `functionality` is a set, and all `functionality`
implementations expect the `service` attribute to be a `defnixos` service that
will be run on the deployment target. In addition, some implementations may
provide semantics for other attributes. For example, an `ipsec` implementation
wrapper could take a set of functionalities with the optional `secure-upstreams`
attribute specifying a set of upstream hosts the functionality requires to
connect to via ipsec transport, and pass along a set of functionalities to the
wrapped implementation to run the given services *and* set up the ipsec
connections.
