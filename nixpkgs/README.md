nixpkgs
=======

Packages imported directly from nixpkgs. By default all packages should
be pulled from a fixed revision of nixpkgs, and packages should not be
changed to pull from a new revision barring explicit reason to do so.

These packages should not be used directly, instead they should be
wrapped in relevant values in `build-support` or `pkgs`.
