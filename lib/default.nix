let
  lib = {
    # Map a function taking an attribute name and the corresponding
    # value and returning a new value over a set.
    map-attrs = f: set: builtins.listToAttrs (map (name: {
      inherit name;

      value = f name set.${name};
    }) (builtins.attrNames set));

    # Map a funciton taking a list index and the corresponding element and
    # returning a new value over a list
    imap = f: list: let
      len = builtins.length list;
      go = idx: if idx == len
        then []
        else [ (f idx (builtins.elemAt list idx)) ] ++ (go (idx + 1));
    in go 0;

    # Left fold over lists
    foldl = op: nil: list: let
      length = builtins.length list;

      go = index: if index == 0
        then nil
        else op (go (index - 1)) (builtins.elemAt list (index - 1));
    in go length;

    # Right fold over lists
    fold = op: nil: list: let
      length = builtins.length list;

      go = index: acc: if index == length
        then acc
        else op (builtins.elemAt list index) (go (index + 1) acc);
    in go 0 nil;

    # Get an attribute from a nested attribute path
    # e.g. get-attr-path { foo.bar = null; } [ "foo" "bar" ] == null
    get-attr-path = lib.foldl (set: attr: set.${attr});

    # Get an attribute from a nested attribute path, falling back to def
    # if there is no such attr.
    get-attr-path-or = set: path: def: let
      maybe-get = lib.foldl ({ set, acc }: attr: {
        set = set.${attr};
        acc = acc && set ? ${attr};
      }) { inherit set; acc = true; } path;
    in if maybe-get.acc then maybe-get.set else def;

    # join strings with separator sep
    join = sep: strings: lib.foldl (acc: string: "${acc} ${string}")
      (builtins.head strings) (builtins.tail strings);

    # Make a function composable.
    # Args is a list of either attributes or attribute paths, where
    # each element denotes the path to the arguments for the function
    # at the corresponding index. For example, from the strongswan service:
    #  composable [ [ "defnixos" "activations" ] "pkgs" ] (
    #
    #  activations@{ certs }:
    #
    #  pkgs@{ strongswan, kmod }:
    #
    #  <etc>
    #  )
    # This is a composable function that expects its first set of arguments
    # to come from the defnixos.activations namespace, and the second set from
    # pkgs.
    composable = args: fn: { inherit args fn; };

    # Call a composable function. args is a set with attribute paths
    # corresponding to the arguments passed to composable. For example,
    #  call-composable strongswan-service {
    #    defnixos.activations = { certs = <etc>; };
    #
    #    pkgs = { strongswan = <etc>; kmod = <etc>; };
    #  }
    # would be a way to call the strongswan-service given in the example
    # for the documentation for compose
    call-composable = composable: args:
      call-composable-with-overrides composable args {} {};

    # Import a bunch of subdirectories of the root, passing along lib
    import-subdirs = root: names: builtins.listToAttrs (map (name: {
      inherit name;

      value = import (root + "/${name}") lib;
    }) names);

    # Import a bunch of expressions in the root, passing along lib
    import-exprs = root: names: builtins.listToAttrs (map (name: {
      inherit name;

      value = import (root + "/${name}.nix") lib;
    }) names);

    # Compose a set of composable sets together, using the sets in arg-overrides to
    # override arguments to specific sets. A composable set is a set of functions
    # together with a 'compose' attribute to tie them all together (see lib.compose).
    # 'root' is the top-level set in a multi-nested chain, it should be set to
    # by top-nested-compose for the top-level call and set by the parent
    # nested-compose for each subset.
    nested-compose = set: root: arg-overrides:
      lib.map-attrs (name: { compose, ... }:
        compose root ((arg-overrides.${name} or {}) // ({ all = arg-overrides.all or {}; }))
      ) set;

    # The top-level variant of nested-compose
    top-nested-compose = set: arg-overrides: let
      self = lib.nested-compose set self arg-overrides;
    in self;

    # Compose a set of composable functions together. defaults is the set of
    # default function arguments to call-composable, and arg-overrides is a
    # per-function set of arguments to to pass. arg-overrides.all is applied
    # to each function.
    compose = composables: defaults: arg-overrides:
      lib.map-attrs (name: composable:
        call-composable-with-overrides composable defaults
          (arg-overrides.${name} or {}) (arg-overrides.all or {})
      ) composables;

    defnixos = import ./defnixos.nix lib;
  };

  # Call a composable function, with a set of potential overrides for
  # each argument set. Internal use (not exported)
  call-composable-with-overrides =
    composable: args: specific-overrides: all-overrides: let
      intersect = f: builtins.intersectAttrs (builtins.functionArgs f);
    in lib.foldl (f: arg: f (intersect f (
      if builtins.isList arg
        then (lib.get-attr-path args arg) //
          (lib.get-attr-path-or all-overrides arg {}) //
          (lib.get-attr-path-or specific-overrides arg {})
        else args.${arg} //
          (all-overrides.${arg} or {}) //
          (specific-overrides.${arg} or {})
    ))) composable.fn composable.args;
in lib
