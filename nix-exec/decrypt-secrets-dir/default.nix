defnix: secrets-dirs: let
  # !!! Clean up when we have https://github.com/NixOS/nix/commit/976df480c918f050608f7a23a4a21415c43475c3
  secret-files = dir: builtins.filter (x:
    x != null
  ) (defnix.lib.map-attrs-to-list (name: type:
    if builtins.stringLength name >= 4 &&
      builtins.substring ((builtins.stringLength name) - 4) 4 name == ".gpg"
      then null
      else name
  ) (builtins.readDir dir));

  inherit (defnix.lib.nix-exec) sequence unit bind;

  inherit (defnix.nix-exec) decrypt-file getenv getpass;

  io-pass = bind (getenv "GPG_AGENT_INFO") (env: if env == null
    then getpass "Enter passphrase for deployment key: "
    else unit null);

  dirs = if builtins.isList secrets-dirs
    then secrets-dirs
    else [ secrets-dirs ];
  io-decrypted = bind io-pass (pass: sequence (builtins.concatLists (map (dir:
    map (secret-file:
      defnix.lib.nix-exec.map (value:
        { name = secret-file; inherit value; }
      ) (decrypt-file pass secret-file (dir + "/${secret-file}.gpg"))
    ) (secret-files dir)
  ) dirs)));

  io-cleartext = unit (builtins.concatLists (map (dir: map (secret-file:
    { name = secret-file; value = dir + "/${secret-file}"; }
  ) (secret-files dir)) dirs));
in decrypt: defnix.lib.nix-exec.map builtins.listToAttrs (if decrypt
  then io-decrypted
  else io-cleartext
)
