/* A bootstrap version of fetchgit. It assumes you have git available in
 * the PATH of the evaluating process and that the building process can
 * execute that git.
 *
 * As an exception to the license for this repository as a whole, this file
 * can be included into any project without including the license or copyright
 * notice.
 */
let
  nix-deps = import <nix/config.nix>;
in { url, rev, sha256 }: derivation {
  name = "git-export";

  builder = nix-deps.shell;

  args = [ "-e" "-c" "eval \"$script\"" ];

  system = builtins.currentSystem;

  PATH = builtins.getEnv "PATH";

  script = ''
    mkdir $out
    mkdir download
    cd download
    git clone --bare ${url}
    cd *
    git archive --format=tar ${rev} | tar -x -C $out
    rm -f $out/.gitignore
  '';

  impureEnvVars = [
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
  ];

  preferLocalBuild = true;

  outputHashAlgo = "sha256";

  outputHash = sha256;

  outputHashMode = "recursive";
}
