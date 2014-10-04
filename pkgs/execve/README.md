execve
=======

Execute `filename` with arguments `argv` and environment `envp`

Exit codes
----------

* 212: Failed to execute

Example
--------

`execve "call-foo" "${foo}/bin/foo" [ "foo" "--bar" ] { baz = "qux"; }` will
result in an executable `call-foo` that, when called, calls `${foo}/bin/foo`
with the argument `--bar` and the environment variable `baz` set to `qux`
