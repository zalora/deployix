decrypt-file
=============

Decrypt a `gpg`-encrypted file and add it to the store

Arguments
----------

* `pass`: The key passphrase, or `null` to use the agent.
* `name`: The name to give the decrypted file in the store.
* `path`: The path to the encrypted file

Return
-------

A monadic value that, when run, decrypts the file at `path`, adds it to the
store with name `name`, and yields the resultant store path.

Note that currently nix does not support private files, so any decrypted files
will be readable to anyone who has access to the store!
