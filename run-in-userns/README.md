run-in-userns
=============

`run-in-userns` is a nix function to run a derivation inside of a user
namespace as root in the namespace. It requires `CONFIG_USER_NS` and will
disable chroot builds.
