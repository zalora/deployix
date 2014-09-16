let
  pkgs = system: import <nixpkgs> { inherit system; };
  defnix = system: import ../. { inherit system; pkgs = pkgs system; };
in
{ output-to-argument ? (defnix system).output-to-argument
, cc ? "${(pkgs system).stdenv.gcc}/bin/gcc"
, coreutils ? (pkgs system).coreutils
, system ? builtins.currentSystem
}:

c: let
  base = c.name or baseNameOf (toString c);
in output-to-argument (derivation {
  name = builtins.substring 0 (builtins.stringLength base - 2) base;

  inherit system;

  builder = cc;

  # GCC wrapper uses cat...
  PATH = [ "${coreutils}/bin" ];

  args = [ c "-O3" "-o" "@out" ];
})
