multiplex-activations
======================

Multiplex several activations together, starting the service once any
of them is ready. Speaks the `NOTIFY_SOCKET` protocol.

Activations are called in order. It is up to the semantics of each activation
how the execution environment for the service will be modified, but do note
that `multiplex-activations` does open a single file descriptor before calling
any activations, but it is dup'd to a high fd first.
