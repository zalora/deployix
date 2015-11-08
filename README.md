deployix
=======

The Zalora public nix library.

`deployix` is home to packages and functions that we want to share with the
community but don't fit into upstream `nixpkgs` for whatever reason.
Additionally, it is the repository for `defnixos`, our service-oriented
deployment specification library.

Deployix uses [nix-exec][1]. Its `default.nix` requires you to pass in the
`nix-exec` lib and returns a `nix-exec` IO value. See
`<deployix/defnixos/nixos-wrappers/ipsec-wrapper.nix>` for an example of how you
can use `deployix` when not using `nix-exec` for evaluation.

Organization
-------------

`deployix` currently has the following components:

* `lib`: Pure nix library functions
* `nixpkgs`: Upstream dependencies from `nixpkgs`
* `eval-support`: Functions for calculation at evaluation time that cannot be
  done in pure nix (i.e. require import from derivations)
* `nix-exec`: Native `nix-exec` functions
* `build-support`: Functions and packages expected to be used directly only
  at build time (e.g. compilers)
* `pkgs`: Functions and packages expected to be used at runtime
* `defnixos`: The deployment specification library

See the individual subdirectories for more information.

Filesystem layout
------------------

`deployix` uses the directory hierarchy to automatically provide structure.
In the normal case, adding a new package or function requires simply
creating a subdirectory in the relevant category and writing a `default.nix`.
The `default.nix` should take a `deployix` argument, which contains the entire
set of values in `deployix`. Adding nested subdirectories before the
`default.nix` will result in a nested set being added to the top-level `deployix`
value.

In some cases, having a separate directory for a given function may be
overkill. If a directory contains an `uncomposed.nix` file, it will be
imported and passed the `deployix` lib and the normal recursion is stopped there.
See `<deployix/build-support/uncomposed.nix>` for a concrete example, but as a
convention `uncomposed.nix` should recursively import its current directory and
add any trivial functions to the set that results from that.

Composition and overriding
---------------------------

The top-level `uncomposed.nix` imports the entire `deployix` tree as described
above. The result is expected to be a tree represented as an attribute set,
where the leaf nodes are all functions taking a `deployix` argument. The
top-level `default.nix` ties this all together by calling each such function
with the composed `deployix` set. This means that any leaf values that don't make
sense as a function taking a `deployix` argument (e.g. the deployix lib) need to
be handled manually.

The top-level `default.nix` takes a set of overrides as an argument. As each
leaf function is reached, `default.nix` first checks to see if the overrides
set contains a value at that path, and uses it if so. For example, if the
overrides set is `{ build-support.compile-c = something; }`, then
`deployix.build-support.compile-c` will refer to `something` instead of to
the result of calling `<deployix/build-support/compile-c/default.nix>` with
the full `deployix` set. An overrides set of `{ build-support = {}; }`, however,
will not affect any leaf values as no full path to any leaf is present.

Some examples:

* `(import <deployix> { build-support.cc = "${pkgs.klibc}/bin/klcc"; }).pkgs.notify-readiness`
  will result in a version of `notify-readiness` linked against `klibc` instead of `glibc`.
* `import <deployix> { nixpkgs.haskellPackages.hakyll = import <my-hakyll> { ??? }; }` will
  override the `hakyll` package.

Configuration values
---------------------

In some cases, leaf values may be configurable in some way that doesn't make
sense to express as a function argument. For example, importing `nixpkgs`
requires a `system` argument, but we don't want to have the set of packages
from `nixpkgs` all be functions and have to pass `system` around every time we
want to use one. Instead, `deployix.config` is used to hold configuration values
in a global set that all packages can access. For example,
`deployix.config.system` is used by `nixpkgs` to determine which system to
import the `nixpkgs` checkout with, it is set to `builtins.currentSystem` by
default but can be overridden in the call to `default.nix` (see
`<deployix/defnixos/nixos-wrappers/ipsec-wrapper.nix>` for an example).

Some configuration values affect many different components, such as,
`system`, and these should be set with default values in the top-level
`default.nix`. Others are component-specific, and should be put into a
component-specific namespace in `deployix.config` with default values handled
by the component. For example, if we ever want to make the set of cflags used
globally for `compile-c` to be configurable, we should use something like
`deployix.config.build-support.compile-c.cflags or default-flags` in
`<deployix/build-support/compile-c/default.nix>`.

Native import
-------------

Because some functions in `deployix` (such as those in `nix-exec`) are meant to
run native code on the evaluating machine, the `deployix.native` attribute points
to an import of `deployix` with `config.system` set to `builtins.currentSystem`.
Functions that need it should use `deployix.native` where relevant, so that the
end user can just import `deployix` with `config.system` set to the *target*
system and still evaluate everything on their native host.

[1]: https://github.com/shlevy/nix-exec
