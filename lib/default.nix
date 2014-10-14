let
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

    readDir = builtins.readDir or (throw "defnix requires a nix version >= 1.8pre3843_3f8576a");

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
  };
in lib
