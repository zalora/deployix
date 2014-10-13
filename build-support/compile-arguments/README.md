compile-arguments
==================

`compile-arguments` is a function to write a file containing the passed list
of arguments laid out in such a way as to be usable when directly mapped into
memory. Its primary use is for defnix-internal tools to pass arguments to each
other at runtime. For example, `multiplex-activations` needs to invoke a series
of activations, each of which is a specific symbol in a specific dynamically
shared object and takes arbitrary arguments. Since all of this is configured in
nix expressions, rather than marshall these parameters to some intermediate
format only to parse them again at runtime we just create a compiled arguments
file for each individual activation.

Arguments
-----------

* `name`: The name of the file to create
* `args`: A list of arguments to compile.

Return
-------

A derivation that creates a flat file. The arguments in `args` are written
to the file in order, in the following formats:

* Strings and paths: First a `size_t` representing the size of the string
  (including terminating null) is written, then the `char`s of the string,
  including terminating null, are written.
* ints: A `long` representing the value of the int is written.
* bools: A `bool` (as in `<stdbool.h>`) is written, with value `true` if the
  argument is `true` and `false` if it is `false`.

Example
--------

See `<defnix/defnixos/activations/socket/default.nix>` for an example of
invoking `compile-arguments`, and see
`<defnix/pkgs/multiplex-activations/multiplex-activations.c>` for how the
generated files can be used.
