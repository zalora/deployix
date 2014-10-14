eval-support
=============

These are helper functions to calcualte things at evaluation time, that
cannot be expressed in pure nix (i.e. they require doing an import from
a derivation). In order to support deploying from darwin hosts, these
functions should be careful to distinguish `defnix.config.target-system`,
the system that the final result will be deployed to (i.e. `x86_64-linux`
for current deployments) from `defnix.config.eval-system`, the system that
the deployment is evaluated on.
