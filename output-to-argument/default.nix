let
  defnix = import ../. {};
in
{ runCommand ? defnix.pkgs.runCommand
}:

args: derivation (args //{
  builder = runCommand "output-to-argument" {}
    "gcc -std=c99 -O3 ${./output-to-argument.c} -o $out";
})
