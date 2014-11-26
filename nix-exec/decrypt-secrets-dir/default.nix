defnix: secrets-dir: let
  # !!! Clean up when we have https://github.com/NixOS/nix/commit/976df480c918f050608f7a23a4a21415c43475c3
  secret-files = builtins.filter (x:
    x != null
  ) (defnix.lib.map-attrs-to-list (name: type:
    if builtins.stringLength name >= 4 &&
      builtins.substring ((builtins.stringLength name) - 4) 4 name == ".gpg"
      then null
      else name
  ) (builtins.readDir secrets-dir));

  inherit (defnix.lib.nix-exec) sequence unit bind;

  inherit (defnix.nix-exec) decrypt-file getenv getpass;

  io-pass = bind (getenv "GPG_AGENT_INFO") (env: if env == null
    then getpass "Enter passphrase for deployment key: "
    else unit null);

  io-decrypted = bind io-pass (pass: sequence (map (secret-file:
    defnix.lib.nix-exec.map (value:
      { name = secret-file; inherit value; }
    ) (decrypt-file pass secret-file (secrets-dir + "/${secret-file}.gpg"))
  ) secret-files));

  io-cleartext = unit (map (secret-file:
    { name = secret-file; value = secrets-dir + "/${secret-file}"; }
  ) secret-files);
in decrypt: defnix.lib.nix-exec.map builtins.listToAttrs (if decrypt
  then io-decrypted
  else io-cleartext
)
