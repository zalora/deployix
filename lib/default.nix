nix-exec-lib: let
  lib = {
    # Map a function taking an attribute name and the corresponding
    # value and returning a new value over a set.
    map-attrs = f: set: builtins.listToAttrs (lib.map-attrs-to-list (
      name: value: { inherit name; value = f name value; }
    ) set);

    # Transform a set into a list by mapping a function taking a name and
    # the corresponding value and returning the relevant list entry over a
    # set.
    map-attrs-to-list = f: set:
      map (name: f name set.${name}) (builtins.attrNames set);

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

    # join strings with separator sep
    join = sep: strings: if strings != []
      then lib.foldl (acc: string: "${acc}${sep}${string}")
        (builtins.head strings) (builtins.tail strings)
      else "";

    # Do all elements satisfy the predicate?
    all = pred: lib.fold (elem: acc: (pred elem) && acc) true;

    # Encapsulate the readDir builtin so we can throw a nice error message.
    readDir = builtins.readDir or (throw "defnix requires a nix version >= 1.8pre3843_3f8576a");

    # Recursively import a directory. Directory names are used as attr names,
    # values are set to either:
    #   a) import dir/default.nix
    #   b) import dir/uncomposed.nix lib
    #   c) recursive-import dir
    # depending on whether default.nix or uncomposed.nix exist in the directory.
    # See <defnix/README.md> for some explanation of this behavior
    recursive-import = dir: let
      dirents = lib.readDir dir;

      subdirs = builtins.filter (name: dirents.${name} == "directory")
        (builtins.attrNames dirents);

      import-dir = dir: let
        default = dir + "/default.nix";

        uncomposed = dir + "/uncomposed.nix";
      in if builtins.pathExists default
        then import default
        else if builtins.pathExists uncomposed
          then import uncomposed lib
          else lib.recursive-import dir;
    in builtins.listToAttrs (map (subdir: {
      name = subdir;

      value = import-dir (dir + "/${subdir}");
    }) subdirs);

    # BSD address families
    socket-address-families = {
      AF_UNIX = 0;

      AF_INET6 = 1;
    };

    # Service auto-restart modes
    restart-modes = {
      no = 0; # Don't automatically restart

      always = 1; # Restart whenever it exits
    };

    # Like basename, but if p is a derivation return the name without the hash
    # prefix
    hashless-basename = p: p.name or
      (baseNameOf (builtins.unsafeDiscardStringContext (toString p)));

    # nix-exec IO monad functions
    nix-exec = nix-exec-lib // rec {
      # bind :: m a -> (a -> m b) -> m b (AKA >>=)
      bind = ma: f: lib.nix-exec.join (lib.nix-exec.map f ma);

      # A variadic variant of dlopen that takes an arity and returns a function
      # of that arity, instead of requiring the caller to construct a list
      # of arguments themselves. This is how dlopen worked before nix-exec
      # version 4.
      dlopen-variadic = filename: symbol: arity: let
        go = args: arity: if arity > 0
          then arg: go (args ++ [ arg ]) (arity - 1)
          else nix-exec-lib.dlopen filename symbol args;
      in go [] arity;

      # Take a list whose values are all monadic and return a monadic value
      # that produces a list whose values are the products of running the
      # corresponding values in the original set
      sequence = lib.fold (melem: macc: bind melem (elem:
        nix-exec-lib.map (acc: [ elem ] ++ acc) macc
      )) (nix-exec-lib.unit []);

      # Take a set whose values are all monadic and return a monadic value
      # that yields a set whose values are the results of running the
      # corresponding values in the original set
      # sequence-attrs :: Map String (m a) -> m (Map String a), where 'a' is
      # the sum type over all nix types.
      sequence-attrs = mset: nix-exec-lib.map builtins.listToAttrs (
        lib.fold (name: acc: bind acc (acc:
          lib.nix-exec.map (value: [ { inherit name value; } ] ++ acc) mset.${name}
        )) (lib.nix-exec.unit []) (builtins.attrNames mset)
      );
    };
  };
in lib
