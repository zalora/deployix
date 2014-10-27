getenv
======

Get an environment variable.

Arguments
----------

* `name`: The variable to look up

Return
-------

A monadic value that, when run, looks up `name` in the environment list and
yields the corresponding value or, if there is none, `null`.
