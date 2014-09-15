output-to-argument
===================

`output-to-argument` is a nix function to run a derivation by invoking a
program with some of its arguments replaced with the store path of some nix
output. To replace an argument with the output, precede the output name with
the `@` character. For example:

```nix
output-to-argument {
  name = "foo.o";
  args = [ "${pkgs.gcc}/bin/gcc" "gcc" "-c" ./foo.c "-o" "@out" ];
  system = builtins.currentSystem;
}
```

Will result in a derivation that compiles `foo.c` into an output named `foo.o`.

Escaping
---------

An argument that is *meant* to start with an `@` can be escaped like `\@`. An
argument that is meant to start with a `\` can be escaped like `\\`. Only the
initial character of each argument is checked for escapes.
