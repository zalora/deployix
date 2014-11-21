nixos-qemu-test
================

Deploy a set of functionalities to a NixOS qemu vm and run a test.


Arguments
------------

* `functionalities`: The set of functionalities
* `nixpkgs`: The nixpkgs checkout to use for the evaluation
* `test-command`: The test command to run on the VM

Return
-------

A derivation that builds a qemu vm with the specified `functionalities` running
on it, verifies that the system comes up properly, and runs `test-command` on
the system. If any step fails, including the `test-command`, the derivation
fails.

Note that the `nixpkgs` function to run a qemu VM does not properly handle
evaluating on a different system than the target, so neither does this
function.
