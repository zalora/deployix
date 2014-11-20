compile-plugin
==============

Compile a plugin to a `nix-exec` `dlopen` value.

Arguments
----------

* `flags`: Extra flags to pass to the c++ compiler
* `cc`: The c++ file defining the plugin
* `symbol`: The name of the symbol representing the plugin function
* `arity`: The arity of the plugin

Returns
-------

A monadic value that, when run, compiles `cc` with the flags needed to make it
a DSO (and any additional `flags` passed in) and is otherwise equivalent to the
result of calling the `dlopen` function in the `nix-exec` lib with the resultant
DSO, `symbol`, and `arity` as its arguments.

Properly uses the native versions of compiler and libraries.
