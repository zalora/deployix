nixops-deploy
=============

Deploy a set of functionalities using nixops

Custom functionalities attributes
----------------------------------

* `nixpkgs-src`: The source of nixpkgs to use for evaluation
* `nixops-name`: The name for the deployment in the nixops state db
* `nixops-description`: The description of the deployment for nixops
* `nixops-deploy-target`: The target type for deployment (e.g. `"virtualbox"`)

Return
-------

A monadic value that, when run, creates/modifies deployment `name` and deploys
a machine named `"machine"` running the services specified in `functionalities`,
yielding the result of `spawn`ing `nixops deploy` (see
`<defnix/nix-exec/spawn/README.md`)

Limitations
------------

Currently requires each functionality to match in all of the custom attributes.
Each functionality is deployed to the same machine.
