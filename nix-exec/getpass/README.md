getpass
=======

Get a password

Arguments
----------

* `prompt`: The prompt to display when asking for the password.

Return
-------

A monadic value that, when run, prints `prompt`, turns off echoing on the
terminal, and reads in a password, yielding the read password.
