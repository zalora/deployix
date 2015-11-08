decrypt-secrets-dir
===================

Decrypt a directory of secrets.

Arguments
----------

* `secrets-dir`: The directory of encrypted secrets. There must be two files for
  each secret, one encrypted and ending in `.gpg` and one in the clear with
  dummy values for use in development/testing. If a list, each element is
  treated as a directory, with earlier elements taking precedence in case of
  duplicates.
* `decrypt`: Whether to actually decrypt the secrets or just used the cleartext
  dummy files

Return
------

A monadic value that, when run, decrypts the files in `secrets-dir` if requested
and produces a set mapping filenames to secret paths.

Uses `decrypt-file` under the hood, and thus has the same limitation (see
`<deployix/nix-exec/decrypt-file/README.md>`).
