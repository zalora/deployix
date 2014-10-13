run-script
===========

`run-script` runs a shell script in a derivation.

Arguments
----------

* `name`: The name of the output
* `env`: Extra environment variables to set for the derivation
* `script`: The script to run

Return
-------

A derivation named `name` that runs `script` in `sh` with environment `env`.

Example
--------

`run-script "foo" {} "echo bar > $out"` results in a derivation whose output
is named `foo` and contains the string `bar`.
