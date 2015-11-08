deployix: let
  inherit (deployix) lib;
  inherit (lib) map-attrs nix-exec;
  inherit (nix-exec) sequence-attrs;
  inherit (nix-exec.builtins) fetchgit;
in pathspecs: sequence-attrs (map-attrs (name:
  { repo ? null, url ? "git://github.com/${repo}.git", rev }: fetchgit {
    inherit rev url;
  }
) pathspecs)
