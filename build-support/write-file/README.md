write-file
===========

`write-file` writes a file with given contents.

Arguments
----------

* `name`: The name of the file to write
* `text`: The contents of the file

Return
-------

A derivation whose output is named `name` and whose contents are given by
`text`.

Example
--------

`write-file "foo" "bar"` creates a file named `foo` with contents `bar`.
