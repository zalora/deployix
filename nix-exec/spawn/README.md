spawn
=======

Spawn a program

Arguments
----------

* `file`: The program to run
* `argv`: A list of arguments

Return
-------

A monadic value that, when run, spawns the program specified by `file` with
the arguments in `argv`, waits for it to finish, and yields a set with attribute
`signalled` a boolean indicating if the program was killed due to a signal, and
attribute `code` an int exit code or termination singal. `code` will be `212` if
the program could not be executed (or, of course, if the program itself exits
with code `212`).
