sequence-pathspecs
===================

Fetch a set of repositories

Arguments
----------

* `pathspecs`: The set of pathspecs.

Pathspec
---------

A `pathspec` is a set with the following attributes:

* `repo`: The repository to fetch. It is currently assumed that all
  repositories are public github repos, thus `repo` should be something like
  `NixOS/nixpkgs`. Exactly one of `repo` or `url` must be specified.
* `url`: The full url to the repository to fetch. Exactly one of `repo` or `url`
  must be specified.
* `rev`: The revision to fetch.

Return
-------

A monaic value that, when run, fetches the requested revision of each repo and
yields a set of paths pointing to each checkout.
