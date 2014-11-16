nixops-deploy
=============

Deploy a set of functionalities using nixops

Arguments
----------

* `functionalities`: The set of functionalities
* `target`: The deployment target (currently only "virtualbox" is supported)
* `name`: The name of the deployment in the nixops state database
* `nixpkgs`: The `nixpkgs` checkout to use for the evaluation

Return
-------

A monadic value that, when run, creates/modifies deployment `name` and deploys
a machine named `"machine"` running the services specified in `functionalities`,
yielding the result of `spawn`ing `nixops deploy` (see
`<defnix/nix-exec/spawn/README.md`)
