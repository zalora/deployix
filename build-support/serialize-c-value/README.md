serialize-c-value
==================

`serialize-c-value` is a function to write a C value directly into a file.
The use case is for programs that are never called directly by users but
instead are always called as an implementation of a nix function: rather
than serialize an argument to a string at deployment time and have the
program parse it at run time, we just serialize the value to the format that
the program wants it in memory and the program mmaps it at runtime.

Arguments
-----------

* `name`: The name of the file to create
* `header`: A header to `#include` for type definitions. Can be omitted.
* `type`: The (C) type of the value.
* `value`: The value to serialize.
* `flags`: Extra flags for the C compiler. Can be omitted.

Return
-------

A derivation whose output is a flat file with a serialization of a value
of type `type` that is first zeroed out and then initialized according
to the following rules based on the value of `value`:

* Derivations and paths are converted to string literals
* Non-derivation sets are used to initialize struct/union members, recursively
* Lists are used to initialize arrays, recursively
* `true` is mapped to `1`, `false` to `0`
* Ints are assigned as `long` constants
* Everything else is interpolated directly

Note that the last rule means that if you want to initialize a value to a C
string, you must pass something like `"\"foo\""`, *not* `"foo"`.

Reusing type definitions in single file programs
-------------------------------------------------

Many programs in `deployix` are defined in single self-contained source files.
To facilitate code reuse, `serialize-c-value` defines the `DEFNIX_TYPES_ONLY`
macro before including `header` so that these files can be used as `include`
without their definitions (particularly of `main`) conflicting.

Example
--------

See `<deployix/defnixos/activations/socket/default.nix>` for an example of
invoking `serialize-c-value`, and see
`<deployix/pkgs/multiplex-activations/multiplex-activations.c>` for how the
generated files can be used.
