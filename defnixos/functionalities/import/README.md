import
=======

Import a `functionalities` nix expression with the specified `paths` and with
defnix imported targeting 64-bit Linux.

Arguments
----------

* `functionalities-expr`: The nix expression to be imported
* `pathspecs`: The specifications for needed paths (see
  `<defnix/nix-exec/sequence-pathspecs/README.md>`

Return
------

A monadic value that, when run, checks out the repositories specified in
`pathspecs`, imports and runs the specified `defnix` checkout with
`config.target-system` set to `"x86_64-linux"`, and imports and runs
`functionalities-expr`, passing in the set of checked-out `paths` and the
newly-imported `defnix`, finally yielding a set with `functionalities` pointing
to the value yielded by running the imported `functionalities` expr and `paths`
pointing to the set of checked-out `paths`.

This is to reduce boilerplate for the common use-case where a deployment repo
consists of:

* A set of pathspecs for any repos that the project depends on
* A `functionalities.nix` describing the functionalities offered by the project

Since currently only deployments targeting `"x86_64-linux"` are supported,
`import` ensures that the version of `defnix` used to build up `functionalities`
targets that system.
