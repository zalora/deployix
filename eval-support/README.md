eval-support
=============

These are helper functions to calcualte things at evaluation time, that
cannot be expressed in pure nix (i.e. they require doing an import from
a derivation). In order to support deploying from hosts with different systems
than the evaluation system, these functions should be careful to distinguish
`deployix` from `deployix.native`.
