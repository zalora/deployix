exec
=======

Execute a program

Arguments
----------

* `file`: The program to run
* `argv`: A list of arguments

Return
-------

A monadic value that, when run, executes the program specified by `file` with
the arguments in `argv`. The action never yields a value.
