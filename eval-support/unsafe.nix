rec {
  unsafeDerivation = args: derivation ({
    PATH = builtins.getEnv "PATH";
    system = builtins.currentSystem;
    builder = ./proxy-bash.sh;
    preferLocalBuild = true;
    __noChroot = true;
  } // args);

  shell = name: command: unsafeDerivation {
    inherit name;
    args = ["-c" command];
  };

  # working git must be in $PATH.
  # increase (change) `clock' to trigger updates
  shallow-fetchgit =
    {url, branch ? "master", clock ? 1}:
      shell "${baseNameOf (toString url)}-${toString clock}" ''
        git clone --depth 1 -b ${branch} --recursive ${url} $out
        cd $out
      '';
}
