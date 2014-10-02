{ defnix, pkgs }: with defnix.deflib; let
toolchain = rec {
  callPackage = callPackageWith toolchain;

  inherit pkgs;

  output-to-argument = callPackage ./toolchain/output-to-argument {};

  compile-c = callPackage ./toolchain/compile-c {};

  wait-for-file = callPackage ./toolchain/wait-for-file {};
}; in toolchain
