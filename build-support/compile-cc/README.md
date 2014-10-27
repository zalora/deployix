compile-cc
==========

`compile-cc` is a function to compile a single-file C++ program.

Arguments
----------

* `flags`: List of extra flags to pass to the compiler
* `cc`: The C++ source code

Return
-------

A derivation that creates an executable.

Example
--------

`compile-cc [] ./hello-world.cc` creates a derivation named `hello-world` that
results from compiling `hello-world.cc` with the default flags.
