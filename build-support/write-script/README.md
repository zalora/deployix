write-script
===========

`write-script` writes an executable file with given contents.

Arguments
----------

* `name`: The name of the file to write
* `text`: The contents of the file

Return
-------

A derivation whose output is an executable named `name` and whose contents are
given by `text`.

Example
--------

`write-file "foo" "#!/bin/sh\necho bar"` creates a script named `foo` that prints `bar`.
