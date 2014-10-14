run-with-settings
==================

`run-with-settings` wraps a program by running it with the execution
environment set according to the settings passed in.

Arguments
----------

* `prog`: The program to wrap
* `settings`: The execution environment settings. See the
  `<defnix/pkgs/execve/README.md>` `settings` argument for details.

Specialization
---------------

By default, `run-with-settings` just creates a new program that sets up the
environment as requested and executing the wrapped program. However, some
packages may need different behavior for efficiency or proper semantics. To do
so, the package should have a `run-with-settings` attribute that takes the
`settings` argument and returns the appropriately-modified program. For
example, see the run-with-settings section of
`<defnix/pkgs/multiplex-activations/README.md>`.
