nix-exec
=========

These are native code plugins wrapped in `nix-exec` `dlopen` IO values. In order
to support deploying from hosts with different systems than the evaluation
these functions should be careful to distinguish `deployix` from `deployix.native`.
