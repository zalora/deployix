defnix: let
  inherit (defnix) lib;
  inherit (lib) map-attrs nix-exec;
  inherit (nix-exec) sequence-attrs;
  inherit (nix-exec.builtins) fetchgit;
in pathspecs: sequence-attrs (map-attrs (name: { repo, rev }: fetchgit {
  url = "git://github.com/${repo}.git";
  inherit rev;
}) pathspecs)
