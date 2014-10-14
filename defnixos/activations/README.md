activations
============

These functions define activations, to be used for on-demand service
activation. They describe what conditions will trigger the start of the
service, and pass on resources relevant to those conditions. They are
combined with the service to activate via `defnix.pkgs.multiplex-activations`.

Format
-------

activations are represented by a compiled arguments file (see
`<defnix/build-support/compile-arguments/README.md>` for more details). The
first argument is the name of a dynamic shared object, and the second is the
name of a symbol within that object that resolves to a function taking an
`epoll` file descriptor and a void pointer. At run time, the given function
will be called with a valid `epoll` file descriptor, and the void pointer will
point to just after the second argument in the compiled arguments file (this
can be used to pass additional arguments to the activation function, see the
`bind_sock` functions in `<defnix/defnixos/activations/socket/socket.so.c>` for
an example).
