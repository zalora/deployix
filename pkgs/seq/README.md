seq
=======

Sequence two programs.

Arguments
----------

* `name`: The name of the resultant executable.
* `a`: The first program to run
* `b`: The second program to run

Exit codes
----------

* 212: Failed to execute

Example
--------

`seq "foo-and-bar" foo bar` will result in an executable named foo-and-bar that
runs foo, waits for it to complete, and if it exits successfully runs bar.
