output-to-argument
===================

`output-to-argument` is a nix function to run a derivation by invoking a
program with some of its arguments replaced with the store path of some nix
output.

Arguments
----------

* `drv`: The derivation to run with arguments substituted.

Return
-------

The derivation `drv`, with any arguments starting with an `@` replaced
by the path of the output whose name follows the `@`, and with any arguments
starting with `\@` or `\\' passed without the initial backslash and without
any substitution of that argument.

Example
--------

```nix
output-to-argument (derivation {
  name = "foo.o";
  builder = "${pkgs.gcc}/bin/gcc";
  args = [ "-c" ./foo.c "-o" "@out" ];
  system = builtins.currentSystem;
})
```

will result in a derivation that compiles `foo.c` into an output named `foo.o`.
