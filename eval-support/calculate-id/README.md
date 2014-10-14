calculate-id
==============

`calculate-id` is a function to calculate a user or group ID from a name.

Arguments
---------

* `name`: The name whose ID we need.

Return
-------

An integer ID, with low probability of collisions. Uses a truncation of the
sha256sum of the username, with a facility for explicitly mapping specific
names (such as root -> 0).

Example
--------

`calculate-id root` gives `0`.
