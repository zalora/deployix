extract-context
===============

Extract the context out of a nix string

Arguments
----------

* `str`: The string to extract

Return
-------

A set with attribute `string` set to `str` with all contet remove, and attribute
`context` a list whose elements depend on the context strings associated with
str.

In nix, each string is associated with an optionally-emtpy context list. The
elements of the context list keep track of which store paths are needed to make
the string menaingful. For example, if `foo` is a derivation, `"${foo}/bin/foo"`
will be a string whose base value is `"/nix/store/some-hash-foo/bin/foo"` and
whose context list contains an entry denoting that the `"out"` output of
`/nix/store/some-hash-foo.drv` is necessary to use that string. If the string
is used in the definition of another derivation `bar`, then nix will ensure
that the `"out"` output of `foo` is built before building `bar`. This is the
means by which string interpolation in nix expressions keeps track of
dependencies.

There are several types of context (these names are my own, they are not
distinctly named in the upstream documentation/source):

* `source`: This is a reference to a directly-added source file in the store.
  For example, `"${./foo}"` will hold a `source` context pointing to
  `/nix/store/some-hash-foo`, and will require that path to be valid for any
  derivations that used `"${./foo}"` to be built. In the `context` list returned
  by `extract-context`, a `source` context entry will correspond to a set with
  attribute `type` being `"context"`, `subtype` being `"source"`, and `path`
  pointing to the relevant store path.
* `drv`: This is a reference to a derivation path. For example, if `foo` is 
  derivation then `"${foo.drvPath}"` will hold a `drv` context entry pointing
  to `/nix/store/some-hash-foo.drv`, and will require that that path, all of
  its outputs, and all of the outputs of its dependent derivations to be valid
  before building any derivation that depends on that string. In the `context`
  list returned by `extract-context`, a `drv` context entry will correspond to
  a set with attribtue `type` being `"context"`, `subtype` being `"drv"`,
  and `path` pointing to the relevant derivation.
* `output`: This is a reference to an output of a derivation. For example,
  if `foo` is a derivation then `"${foo}"` will hold an `output` context
  pointing to the `"out"` output of `/nix/store/some-hash-foo.drv`, and will
  require that that output be built before building any derivation that depends
  on that string. In the `context` list returned by `extract-context`, an
  `output` context entry will correspond to a set with attribute `type` being
  `"context"`, `subtype` being `"output"`, `output` being the relevant output
  name, and `path` being the relevant derivation path.
* `drv-as-source`: This is a special case where a `derivation` path is treated
  as a source input (that is, its outputs are not built before any referring
  derivation can be built). Its semantics are the same as `source`, except the
  path it points to will be a derivation. It can be obtained by using
  `builtins.unsafeDiscardOutputDependency`. In the `context` list returned by
  `extract-context`, a `drv-as-source` context entry will correspond to a set
  with attribute `type` being `"context"`, `subtype` being `"drv-as-source"`,
  and `path` as the relevant derivation path.
