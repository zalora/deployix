emulate-inetd
=============

Emulated `inetd(8)`-style activation for a single service.

Arguments
---------

* `prog`: The program to run with a connected socket as `stdin`

Socket activation
------------------

Assumes a listening socket at fd `3`, meant to be used with
`multiplex-activations`.
