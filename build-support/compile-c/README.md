compile-c
==========

`compile-c` is a function to compile a single-file C program.

Arguments
----------

* `flags`: List of extra flags to pass to the compiler
* `c`: The C source code

Return
-------

A derivation that creates an executable.

Example
--------

`compile-c [] ./hello-world.c` creates a derivation named `hello-world` that
results from compiling `hello-world.c` with the default flags.
