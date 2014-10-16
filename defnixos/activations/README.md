activations
============

These functions define activations, to be used for on-demand service
activation. They describe what conditions will trigger the start of the
service, and pass on resources relevant to those conditions. They are
combined with the service to activate via `defnix.pkgs.multiplex-activations`.

Format
-------

activations are represented by a serialized C value (see
`<defnix/build-support/serialize-c-value/README.md>` for more details). The
value must be of a type whose pointers can be cast to a pointer to an
`activation_header(f_sz, s_sz)`. `sizes.filename_size` should be set equal
to `f_sz`, `sizes.symbol_size` sould be set equal to `s_sz`, `filename` should
be a null-terminated path to a dynamic shared object, and `symbol` should be a
null-terminated symbol name within that shared object that resolves to a
function that takes an `epoll` file descriptor and a pointer to a
`struct activation_header_sizes`. At run time, the function will be called
with a valied `epoll` file descriptor, and the pointer will point to the
beginning of the serialized value (this can be used to pass additional
arguments to the activation function, see the `bind_sock` function in
`<defnix/defnixos/activations/socket/socket.so.c>` for an example). The
activation function is expected to modify the `epoll` set so that a call
to `epoll_wait` will return when the service should be started.
